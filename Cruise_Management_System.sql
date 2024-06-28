-- CS4400: Introduction to Database Systems: Monday, June 10, 2024
-- Simple Cruise Management System Course Project Database TEMPLATE (v0)
-- Team 03
-- George Dong (gdong37)
-- Maya Mathur (mmathur38)
-- Team Member Name (GT username)
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

-- Tables used for the routing of cruises
-- Includes the entities: route, leg, port
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
