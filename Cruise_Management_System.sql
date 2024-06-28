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

create table ship(
    primary key (shipID),
    name varchar(50) not null, 
    speed varchar(50),
    max_cap int(50),
    curr_cap int(50),
    filled boolean(50),
    next_time varchar(50),
    status varchar(50),
    locID varchar(50), 
    cruiseID varchar(50),
    cruiselineID varchar(50),
    foreign key (locID) references Location(locID),
    foreign key (cruiseID) references Cruise(legID),
    foreign key (cruiselineID) references Cruiseline(cruiselineID)
);
create table river(
    primary key (riverID),
    name varchar(50),
    uses_paddles boolean(50),
    locID varchar(50),
    foreign key (locID) references Location(locID),
);
create table ocean_liner(
    primary key (oceanlinerID),
    name varchar(50),
    lifeboats varchar(50),
    locID varchar(50),
    foreign key (locID) references Location(locID),
);

-- Tables used for the tracking cruiselines and cruises
-- Includes the entities: cruise, cruiseline
create table cruiseline(
    cruiselineID varchar(50) primary key
);

CREATE TABLE cruise (
    cruiseID varchar(50) PRIMARY KEY,
    cost varchar(100),
    routeID varchar(50),
    FOREIGN KEY (routeID) REFERENCES route(routeID),
);

------------------------- Insert Statements for routing group
use cruise_tracking;
-- TODO - locationID
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
    
insert into cruise(cruiseID, cruiselineID, cost, progress, next_time, cstatus, shipID) values
	('rc_10', 'Royal Caribbean', '200', '1', '1970-01-01 08:00:00', 'sailing', 'Symphony of the Seas'),
	('cn_38', 'Carnival', '200', '2', '1970-01-01 14:30:00', 'sailing', 'Carnival Vista'),
	('dy_61', 'Disney', '200', '0', '1970-01-01 09:30:00', 'docked', 'Disney Dream'),
	('nw_20', 'Norwegian', '300','2', '1970-01-01 11:00:00', 'sailing', 'Norwegian Bliss'),
	('pn_16', 'Ponant', '400','1', '1970-01-01 14:00:00', 'sailing', 'Le Lyrial'),
	('rc_51', 'Royal Caribbean', '100','3', '1970-01-01 11:30:00', 'docked', 'Oasis of the Seas');