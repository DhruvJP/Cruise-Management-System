-- CS4400: Introduction to Database Systems: Monday, June 10, 2024
-- Simple Cruise Management System Course Project Database TEMPLATE (v0)
-- Team 03
-- George Dong (gdong37)
-- Team Member Name (GT username)
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
    primary key (portID)
);

create table leg(
    legID varchar(50) not null,
    distance varchar(50),
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
    legSequence int not null,
    legID varchar(50) not null,
    foreign key (routeID) references route(routeID),
    foreign key (legID) references leg(legID),
    primary key (routeID, legSequence)
);

------------------------- Insert Statements for routing group
use cruise_tracking;
-- TODO - locationID
insert into port (portID, portName, portCity, portState, portCountry) values
    ('MIA', 'Port of Miami', 'Miami', 'Florida', 'USA'),
    ('EGS', 'Port Everglades', 'Fort Lauderdale', 'Florida', 'USA'),
    ('CZL', 'Port of Cozumel', 'Cozumel', 'Quintana Roo', 'MEX'),
    ('CNL', 'Port Canaveral', 'Cape Canaveral', 'Florida', 'USA'),
    ('NSU', 'Port of Nassau', 'Nassau', 'New Providence ', 'BHS'),
    ('BCA', 'Port of Barcelona', 'Barcelona', 'Catalonia', 'ESP'),
    ('CVA', 'Port of Civitavecchia', 'Civitavecchia', 'Lazio', 'ITA'),
    ('VEN', 'Port of Venice', 'Venice', 'Veneto', 'ITA'),
    ('SHA', 'Port of Southampton', 'Southampton', 'NULL', 'GBR'),
    ('GVN', 'Port of Galveston', 'Galveston', 'Texas', 'USA'),
    ('SEA', 'Port of Seattle', 'Seattle', 'Washington', 'USA'),
    ('SJN', 'Port of San Juan', 'San Juan', 'Puerto Rico', 'USA'),
    ('NOS', 'Port of New Orleans', 'New Orleans', 'Louisiana', 'USA'),
    ('SYD', 'Port of Sydney', 'Sydney', 'New South Wales', 'AUS'),
    ('TMP', 'Port of Tampa Bay', 'Tampa Bay', 'Florida', 'USA'),
    ('VAN', 'Port of Vancouver', 'Vancouver', 'British Columbia', 'CAN'),
    ('MAR', 'Port of Marseille', 'Marseille', 'Provence-Alpes-Côte d''Azur', 'FRA'),
    ('COP', 'Port of Copenhagen', 'Copenhagen', 'Hovedstaden', 'DEN'),
    ('BRI', 'Port of Bridgetown', 'Bridgetown', 'Saint Michael', 'BRB'),
    ('PIR', 'Port of Piraeus', 'Piraeus', 'Attica', 'GRC'),
    ('STS', 'Port of St. Thomas', 'Charlotte Amalie', 'St. Thomas', 'USVI'),
    ('STM', 'Port of Stockholm', 'Stockholm', 'Stockholm County', 'SWE'),
    ('LAS', 'Port of Los Angeles', 'Los Angeles', 'California', 'US');

insert into leg (legID, departurePort, arrivalPort, distance) values
    ('leg_2', 'MIA', 'NSU', '190'),
    ('leg_1', 'NSU', 'SJN', '792'),
    ('leg_31', 'LAS', 'SEA', '1139'),
    ('leg_14', 'SEA', 'VAN', '126'),
    ('leg_4', 'MIA', 'EGS', '29'),
    ('leg_47', 'BCA', 'MAR', '185'),
    ('leg_15', 'MAR', 'CVA', '312'),
    ('leg_27', 'CVA', 'VEN', '941'),
    ('leg_33', 'VEN', 'PIR', '855'),
    ('leg_64', 'STM', 'COP', '427'),
    ('leg_78', 'COP', 'SHA', '803');

insert into route values
    ('americas_one'),
    ('americas_three'),
    ('americas_two'),
    ('big_mediterranean_loop'),
    ('euro_north'),
    ('euro_south');