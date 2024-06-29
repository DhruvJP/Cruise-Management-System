-- CS4400: Introduction to Database Systems: Monday, June 10, 2024
-- Simple Cruise Management System Course Project Database TEMPLATE (v0)
-- Team 03
-- George Dong (gdong37)
-- Maya Mathur (mmathur38)
-- Dhruv Patel (dpatel700)
-- Team Member Name (GT username)
-- Team Member Name (GT username)
-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump file.
-- This file must run without error for credit.
/* This is a standard preamble for most of our scripts. The intent is to establish
a consistent environment for the database behavior. */

set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'cruise_tracking';
drop database if exists cruise_tracking;
create database if not exists cruise_tracking;
use cruise_tracking;

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and
foreign key
declarations, and data insertion statements here. You may sequence them in any
order that
works for you. When executed, your statements must create a functional database
that contains
all of the data, and supports as many of the constraints as reasonably possible. */

/* GENERAL INFO
identifying attributes - 50 or fewer alphanumeric characters
dates - yyyy-mm-dd
first / lastnames - 100 or fewer characters
general attributes - 100 or fewer characters (unless specified)
data specifications CAN change*/
create table location(
	locID varchar(50) not null,
	primary key (locID)
);

-- Tables used for the routing of cruises
-- Includes the entities: route, leg, port
create table person(
	personID varchar(50) not null,
    fname varchar(100),
    lname varchar(100),
    primary key (personID)
);

create table passenger(
	pID varchar(50),
    miles varchar(100),
    funds varchar(100),
    primary key (pID),
    foreign key (pID) references person(personID)
);

create table port(
    portID varchar(50) not null,
    portName varchar(100),
    portCity varchar(100),
    portState varchar(100),
    portCountry varchar(100),
    location varchar(50) default null,
    primary key (portID),
    foreign key (location) references location(locID)
);

create table leg(
    legID varchar(50) not null,
    distance varchar(100),
    arrivalPort varchar(50) not null,
    departurePort varchar(50) not null,
    primary key (legID),
    foreign key (arrivalPort) references port(portID),
    foreign key (departurePort) references port(portID)
);

create table route(
    routeID varchar(50) not null,
    primary key (routeID)
);

create table contains(
    routeID varchar(50) not null,
    sequence varchar(50) not null,
    legID varchar(50) not null,
    foreign key (routeID) references route(routeID),
    foreign key (legID) references leg(legID),
    primary key (routeID, sequence, legID)
);


create table occupies(
	locID varchar(50) not null,
    personID varchar(50) not null,
    foreign key (locID) references location(locID),
	foreign key (personID) references person(personID),
    primary key (locID, personID)
);

-- Tables used for the tracking cruiselines and cruises
-- Includes the entities: cruise, cruiseline
create table cruiseline(
    cruiselineID varchar(50) primary key
);

create table ship(
    cruiselineID varchar(50) not null,
    name varchar(50), 
    speed varchar(100),
    max_cap int(100),
    locID varchar(50), 
    foreign key (locID) references location(locID),
    foreign key (cruiselineID) references cruiseline(cruiselineID),
    primary key (cruiselineID, name)
);

CREATE INDEX index_name ON ship (name);

create table river(
    cruiselineID varchar(50),
    name varchar(50), 
    uses_paddles boolean,
    foreign key (cruiselineID) references ship(cruiselineID),
    foreign key (name) references ship(name),
    primary key (cruiselineID, name)
);
create table ocean_liner(
    cruiselineID varchar(50) not null,
    name varchar(50) not null, 
    lifeboats varchar(100),
    foreign key (cruiselineID) references ship(cruiselineID),
    foreign key (name) references ship(name),
    primary key (cruiselineID, name)
);

CREATE TABLE cruise (
    cruiseID varchar(50) PRIMARY KEY,
    cost int(100),
    routeID varchar(50) not null,
    FOREIGN KEY (routeID) REFERENCES route(routeID)
);

create table support(
    cruiseID varchar(50),
    cruiselineID varchar(50),
    name varchar(50),
    progress varchar(100),
    status varchar(100),
    next_time varchar(100),
    foreign key (cruiseID) references cruise(cruiseID),
    foreign key (cruiselineID) references ship(cruiselineID),
    foreign key (name) references ship(name),
    primary key (cruiseID, cruiselineID, name)
);

------------------------- Insert Statements for routing group
use cruise_tracking;
insert into location (locID) values
	('port_1'),
	('port_2'),
	('port_3'),
	('port_10'),
	('port_17'),
	('ship_1'),
	('ship_5'),
	('ship_8'),
	('ship_13'),
	('ship_20'),
	('port_12'),
	('port_14'),
	('port_15'),
	('port_20'),
	('port_4'),
	('port_16'),
	('port_11'),
	('port_23'),
	('port_7'),
	('port_6'),
	('port_13'),
	('port_21'),
	('port_18'),
	('port_22'),
	('ship_6'),
	('ship_25'),
	('ship_7'),
	('ship_21'),
	('ship_24'),
	('ship_23'),
	('ship_18'),
	('ship_26'),
	('ship_22');

insert into port (portID, portName, portCity, portState, portCountry, location) values
    ('MIA', 'Port of Miami', 'Miami', 'Florida', 'USA', 'port_1'),
    ('EGS', 'Port Everglades', 'Fort Lauderdale', 'Florida', 'USA', 'port_2'),
    ('CZL', 'Port of Cozumel', 'Cozumel', 'Quintana Roo', 'MEX', 'port_3'),
    ('CNL', 'Port Canaveral', 'Cape Canaveral', 'Florida', 'USA', 'port_4'),
    ('NSU', 'Port of Nassau', 'Nassau', 'New Providence ', 'BHS', NULL),
    ('BCA', 'Port of Barcelona', 'Barcelona', 'Catalonia', 'ESP', 'port_6'),
    ('CVA', 'Port of Civitavecchia', 'Civitavecchia', 'Lazio', 'ITA', 'port_7'),
    ('VEN', 'Port of Venice', 'Venice', 'Veneto', 'ITA', 'port_14'),
    ('SHA', 'Port of Southampton', 'Southampton', NULL, 'GBR', NULL),
    ('GVN', 'Port of Galveston', 'Galveston', 'Texas', 'USA', 'port_10'),
    ('SEA', 'Port of Seattle', 'Seattle', 'Washington', 'USA', 'port_11'),
    ('SJN', 'Port of San Juan', 'San Juan', 'Puerto Rico', 'USA', 'port_12'),
    ('NOS', 'Port of New Orleans', 'New Orleans', 'Louisiana', 'USA', 'port_13'),
    ('SYD', 'Port of Sydney', 'Sydney', 'New South Wales', 'AUS', NULL),
    ('TMP', 'Port of Tampa Bay', 'Tampa Bay', 'Florida', 'USA', 'port_15'),
    ('VAN', 'Port of Vancouver', 'Vancouver', 'British Columbia', 'CAN', 'port_16'),
    ('MAR', 'Port of Marseille', 'Marseille', 'Provence-Alpes-Côte d''Azur', 'FRA', 'port_17'),
    ('COP', 'Port of Copenhagen', 'Copenhagen', 'Hovedstaden', 'DEN', 'port_18'),
    ('BRI', 'Port of Bridgetown', 'Bridgetown', 'Saint Michael', 'BRB', NULL),
    ('PIR', 'Port of Piraeus', 'Piraeus', 'Attica', 'GRC', 'port_20'),
    ('STS', 'Port of St. Thomas', 'Charlotte Amalie', 'St. Thomas', 'USVI', 'port_21'),
    ('STM', 'Port of Stockholm', 'Stockholm', 'Stockholm County', 'SWE', 'port_22'),
    ('LAS', 'Port of Los Angeles', 'Los Angeles', 'California', 'USA', 'port_2');

insert into leg (legID, departurePort, arrivalPort, distance) values
    ('leg_2', 'MIA', 'NSU', '190mi'),
    ('leg_1', 'NSU', 'SJN', '792mi'),
    ('leg_31', 'LAS', 'SEA', '1139mi'),
    ('leg_14', 'SEA', 'VAN', '126mi'),
    ('leg_4', 'MIA', 'EGS', '29mi'),
    ('leg_47', 'BCA', 'MAR', '185mi'),
    ('leg_15', 'MAR', 'CVA', '312mi'),
    ('leg_27', 'CVA', 'VEN', '941mi'),
    ('leg_33', 'VEN', 'PIR', '855mi'),
    ('leg_64', 'STM', 'COP', '427mi'),
    ('leg_78', 'COP', 'SHA', '803mi');

insert into route values
    ('americas_one'),
    ('americas_three'),
    ('americas_two'),
    ('big_mediterranean_loop'),
    ('euro_north'),
    ('euro_south');

insert into contains (routeID, legID, sequence) values
    ('americas_one', 'leg_2', '0'),
    ('americas_one', 'leg_1', '1'),
    ('americas_three', 'leg_31', '0'),
    ('americas_three', 'leg_14', '1'),
    ('americas_two', 'leg_4', '0'),
    ('big_mediterranean_loop', 'leg_47', '0'),
    ('big_mediterranean_loop', 'leg_15', '1'),
    ('big_mediterranean_loop', 'leg_27', '2'),
    ('big_mediterranean_loop', 'leg_33', '3'),
    ('euro_north', 'leg_64', '0'),
    ('euro_north', 'leg_78', '1'),
    ('euro_south', 'leg_47', '0'),
    ('euro_south', 'leg_15', '1');

insert into cruiseline(cruiselineID) values
	('Royal Caribbean'),
	('Carnival'),
	('Norwegian'),
	('MSC'),
	('Princess'),
	('Celebrity'),
	('Disney'),
	('Holland America'),
	('Costa'),
	('P&O Cruises'),
	('AIDA'),
	('Viking Ocean'),
	('Silversea'),
	('Regent'),
	('Oceania'),
	('Seabourn'),
	('Cunard'),
	('Azamara'),
	('Windstar'),
	('Hurtigruten'),
	('Paul Gauguin Cruises'),
	('Celestyal Cruises'),
	('Saga Cruises'),
	('Ponant'),
	('Star Clippers'),
	('Marella Cruises');

insert into ship (cruiselineID, name, max_cap, speed, locID) values
    ('Royal Caribbean', 'Symphony of the Seas', '6680', '22', 'ship_1'),
    ('Carnival', 'Carnival Vista', '3934', '23', 'ship_23'),
    ('Norwegian', 'Norwegian Bliss', '4004', '22.5', 'ship_24'),
    ('MSC', 'Meraviglia', '4488', '22.7', 'ship_22'),
    ('Princess', 'Crown Princess', '3080', '23', 'ship_5'),
    ('Celebrity', 'Celebrity Edge', '2908', '22', 'ship_6'),
    ('Disney', 'Disney Dream', '4000', '23.5', 'ship_7'),
    ('Holland America', 'MS Nieuw Statendam', '2666', '23', 'ship_8'),
    ('Costa', 'Costa Smeralda', '6554', '23', null),
    ('P&O Cruises', 'Iona', '5200', '22.6', null),
    ('AIDA', 'AIDAnova', '6600', '21.5', null),
    ('Viking Ocean', 'Viking Orion', '930', '20', null),
    ('Silversea', 'Silver Muse', '596', '19.8', 'ship_13'),
    ('Regent', 'Seven Seas Explorer', '750', '19.5', null),
    ('Oceania', 'Marina', '1250', '20', null),
    ('Seabourn', 'Seabourn Ovation', '604', '19', null),
    ('Cunard', 'Queen Mary 2', '2691', '30', null),
    ('Azamara', 'Azamara Quest', '686', '18.5', 'ship_18'),
    ('Royal Caribbean', 'Oasis of the Seas', '1325', '18', 'ship_25'),
    ('Windstar', 'Wind Surf', '342', '15', 'ship_20'),
    ('Hurtigruten', 'MS Roald Amundsen', '530', '15.5', 'ship_21'),
    ('Paul Gauguin Cruises', 'Paul Gauguin', '332', '18', null),
    ('Celestyal Cruises', 'Celestyal Crystal', '1200', '18.5', null),
    ('Saga Cruises', 'Spirit of Discovery', '999', '21', null),
    ('Ponant', 'Le Lyrial', '264', '16', 'ship_26'),
    ('Star Clippers', 'Royal Clipper', '227', '17', null),
    ('Marella Cruises', 'Marella Explorer', '1924', '21.5', null);

insert into ocean_liner (cruiselineID, name, lifeboats) values
    ('Royal Caribbean', 'Symphony of the Seas', '20'),
    ('Carnival', 'Carnival Vista', '20'),
    ('Norwegian', 'Norwegian Bliss', '15'),
    ('MSC', 'Meraviglia', '20'),
    ('Princess', 'Crown Princess', '20'),
    ('Celebrity', 'Celebrity Edge', '20'),
    ('Disney', 'Disney Dream', '20'),
    ('Holland America', 'MS Nieuw Statendam', '30'),
    ('P&O Cruises', 'Iona', '20'),
    ('AIDA', 'AIDAnova', '35'),
    ('Viking Ocean', 'Viking Orion', '20'),
    ('Silversea', 'Silver Muse', '30'),
    ('Regent', 'Seven Seas Explorer', '20'),
    ('Oceania', 'Marina', '25'),
    ('Seabourn', 'Seabourn Ovation', '20'),
    ('Cunard', 'Queen Mary 2', '40'),
    ('Royal Caribbean', 'Oasis of the Seas', '30'),
    ('Saga Cruises', 'Spirit of Discovery', '2'),
    ('Marella Cruises', 'Marella Explorer', '2');

insert into river (cruiselineID, name, uses_paddles) values
    ('Azamara', 'Azamara Quest', TRUE),
    ('Windstar', 'Wind Surf', FALSE),
    ('Hurtigruten', 'MS Roald Amundsen', TRUE),
    ('Celestyal Cruises', 'Celestyal Crystal', FALSE),
    ('Ponant', 'Le Lyrial', TRUE),
    ('Star Clippers', 'Royal Clipper', TRUE);

insert into cruise (cruiseID, routeID, cost) values
    ('rc_10', 'americas_one', 200),
    ('cn_38', 'americas_three', 200),
    ('dy_61', 'americas_two', 200),
    ('nw_20', 'euro_north', 300),
    ('pn_16', 'euro_south', 400),
    ('rc_51', 'big_mediterranean_loop', 100);

insert into support (cruiseID, cruiselineID, name, progress, status, next_time) values
    ('rc_10', 'Royal Caribbean', 'Symphony of the Seas', '1', 'sailing', '08:00:00'),
    ('cn_38', 'Carnival', 'Carnival Vista', '2', 'sailing', '14:30:00'),
    ('dy_61', 'Disney', 'Disney Dream', '0', 'docked', '09:30:00'),
    ('nw_20', 'Norwegian', 'Norwegian Bliss', '2', 'sailing', '11:00:00'),
    ('pn_16', 'Ponant', 'Le Lyrial', '1', 'sailing', '14:00:00'),
    ('rc_51', 'Royal Caribbean', 'Oasis of the Seas', '3', 'docked', '11:30:00');