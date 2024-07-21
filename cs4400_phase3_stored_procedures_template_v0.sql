-- CS4400: Introduction to Database Systems: Monday, July 1, 2024
-- Simple Cruise Management System Course Project Stored Procedures [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'cruise_tracking';
use cruise_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_ship()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ship.  A new ship must be sponsored
by an existing cruiseline, and must have a unique name for that cruiseline. 
A ship must also have a non-zero seat capacity and speed. A ship
might also have other factors depending on it's type, like paddles or some number
of lifeboats.  Finally, a ship must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_ship;
delimiter //
create procedure add_ship (in ip_cruiselineID varchar(50), in ip_ship_name varchar(50),
	in ip_max_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_ship_type varchar(100), in ip_uses_paddles boolean, in ip_lifeboats integer)
sp_main: begin

end //
delimiter ;

-- [2] add_port()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new port.  A new port must have a unique
identifier along with a new and database-wide unique location if it will be used
to support ship arrivals and departures.  A port may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_port;
delimiter //
create procedure add_port (in ip_portID char(3), in ip_port_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin

end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at a port, on a ship, or both, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a crew role or a passenger role (exclusively).  As crew,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of rewards miles, along with a
certain amount of funds needed to purchase cruise packages. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin

end //
delimiter ;

-- [4] grant_or_revoke_crew_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a crew member's license.  If the license
doesn't exist, it must be created; and, if it already exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_crew_license;
delimiter //
create procedure grant_or_revoke_crew_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

end //
delimiter ;

-- [5] offer_cruise()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new cruise.  The cruise can be defined before
a ship has been assigned for support, but it must have a valid route.  And
the ship, if designated, must not be in use by another cruise.  The cruise
can be started at any valid location along the route except for the final stop,
and it will begin docked.  You must also include when the cruise will
depart along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_cruise;
delimiter //
create procedure offer_cruise (in ip_cruiseID varchar(50), in ip_routeID varchar(50),
    in ip_support_cruiseline varchar(50), in ip_support_ship_name varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin

end //
delimiter ;

-- [6] cruise_arriving()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a cruise arriving at the next port
along its route.  The status should be updated, and the next_time for the cruise 
should be moved 8 hours into the future to allow for the passengers to disembark 
and sight-see for the next leg of travel.  Also, the crew of the cruise should receive 
increased experience, and the passengers should have their rewards miles updated. 
Everyone on the cruise must also have their locations updated to include the port of 
arrival as one of their locations, (as per the scenario description, a person's location 
when the ship docks includes the ship they are on, and the port they are docked at). */
-- -----------------------------------------------------------------------------
drop procedure if exists cruise_arriving;
delimiter //
create procedure cruise_arriving (in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [7] cruise_departing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a cruise departing from its current
port towards the next port along its route.  The time for the next leg of
the cruise must be calculated based on the distance and the speed of the ship. The progress
of the ship must also be incremented on a successful departure, and the status must be updated.
We must also ensure that everyone, (crew and passengers), are back on board. 
If the cruise cannot depart because of missing people, then the cruise must be delayed 
for 30 minutes. You must also update the locations of all the people on that cruise,
so that their location is no longer connected to the port the cruise departed from, 
(as per the scenario description, a person's location when the ship sets sails only includes 
the ship they are on and not the port of departure). */
-- -----------------------------------------------------------------------------
drop procedure if exists cruise_departing;
delimiter //
create procedure cruise_departing (in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [8] person_boards()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the location for people, (crew and passengers), 
getting on a in-progress cruise at its current port.  The person must be at the same port as the cruise,
and that person must either have booked that cruise as a passenger or been assigned
to it as a crew member. The person's location cannot already be assigned to the ship
they are boarding. After running the procedure, the person will still be assigned to the port location, 
but they will also be assigned to the ship location. */
-- -----------------------------------------------------------------------------
drop procedure if exists person_boards;
delimiter //
create procedure person_boards (in ip_personID varchar(50), in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [9] person_disembarks()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the location for people, (crew and passengers), 
getting off a cruise at its current port.  The person must be on the ship supporting 
the cruise, and the cruise must be docked at a port. The person should no longer be
assigned to the ship location, and they will only be assigned to the port location. */
-- -----------------------------------------------------------------------------
drop procedure if exists person_disembarks;
delimiter //
create procedure person_disembarks (in ip_personID varchar(50), in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [10] assign_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a crew member as part of the cruise crew for a given
cruise.  The crew member being assigned must have a license for that type of ship,
and must be at the same location as the cruise's first port. Also, the cruise must not 
already be in progress. Also, a crew member can only support one cruise (i.e. one ship) at a time. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_crew;
delimiter //
create procedure assign_crew (in ip_cruiseID varchar(50), ip_personID varchar(50))
sp_main: begin
if not exists (select cruiseID, ip_personID from cruise join ship 
on cruise.support_ship_name = ship.ship_name 
and cruise.support_cruiseline = ship.cruiselineID
join licenses on licenses.license = ship.ship_type where cruise.cruiseID = ip_cruiseID and ip_personID = licenses.personID)
then
	if not exists (select cr.personID from crew cr join cruise c on cr.assigned_to = c.cruiseID
    join route_path r on c.routeID = r.routeID 
    join leg on r.legID = leg.legID 
    join ship_port p on leg.arrival = p.portID 
    join person_occupies po on p.locationID = po.locationID 
    where c.cruiseID = ip_cruiseID and po.personID = ip_personID)
    then
		if not exists (select cruiseID from cruise where progress = '0' and cruiseID = ip_cruiseID)
        then
			if not exists (select assigned_to from crew where crew.personID = ip_personID and (assigned_to is null or assigned_to = ''))
			then leave sp_main; end if; end if; end if; end if;
if exists (select cruiseID, ip_personID from cruise join ship 
on cruise.support_ship_name = ship.ship_name 
and cruise.support_cruiseline = ship.cruiselineID
join licenses on licenses.license = ship.ship_type where cruise.cruiseID = ip_cruiseID and ip_personID = licenses.personID)
then 
	if exists (select cr.personID from crew cr join cruise c on cr.assigned_to = c.cruiseID
    join route_path r on c.routeID = r.routeID 
    join leg on r.legID = leg.legID 
    join ship_port p on leg.departure = p.portID 
    join person_occupies po on p.locationID = po.locationID 
    where c.cruiseID = ip_cruiseID and po.personID = ip_personID)
    then 
		if exists (select cruiseID from cruise where progress = '0' and cruiseID = ip_cruiseID)
        then 
			if exists (select assigned_to from crew where crew.personID = ip_personID and (assigned_to is null or assigned_to = ''))
			then update crew
            set crew.assigned_to = ip_cruiseID where crew.personID = ip_personID; end if; end if; end if; end if;
    
end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the crew assignments for a given cruise. The
cruise must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_cruiseID varchar(50))
sp_main: begin

end //
delimiter ;

-- [12] retire_cruise()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a cruise that has ended from the system.  The
cruise must be docked, and either be at the start its route, or at the
end of its route.  And the cruise must be empty - no crew or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_cruise;
delimiter //
create procedure retire_cruise (in ip_cruiseID varchar(50))
sp_main: begin
create temporary table if not exists max_sequences as (
        select max(sequence) as last_sequence, routeID 
        from route_path 
        group by routeID
    );
if not exists (select cruiseID from cruise 
                   join max_sequences on max_sequences.routeID = cruise.routeID
                   where (progress = max_sequences.last_sequence or progress = '0') 
                   and ship_status = 'docked' 
                   and cruiseID = ip_cruiseID) then
        leave sp_main; 
    end if;
    if exists (select cruiseID from cruise 
               join ship on support_ship_name = ship_name 
               join person_occupies on ship.locationID = person_occupies.locationID 
               where cruiseID = ip_cruiseID) 
       and not exists (select assigned_to from crew where assigned_to = ip_cruiseID)
       and not exists (select cruiseID from passenger_books where cruiseID = ip_cruiseID) then
        leave sp_main; 
    end if;
    
    if exists (select cruiseID from cruise 
               join max_sequences on max_sequences.routeID = cruise.routeID
               where (progress = max_sequences.last_sequence or progress = '0') 
               and ship_status = 'docked' 
               and cruiseID = ip_cruiseID) then
        if not exists (select cruiseID from cruise 
                       join ship on support_ship_name = ship_name 
                       join person_occupies on ship.locationID = person_occupies.locationID 
                       where cruiseID = ip_cruiseID) 
           and not exists (select assigned_to from crew where assigned_to = ip_cruiseID)
           and not exists (select cruiseID from passenger_books where cruiseID = ip_cruiseID) then
            delete from cruise where cruiseID = ip_cruiseID;
        end if;
    end if;
        drop temporary table if exists max_sequences;
end //
delimiter ;

-- [13] cruises_at_sea()
-- -----------------------------------------------------------------------------
/* This view describes where cruises that are currently sailing are located. */
-- -----------------------------------------------------------------------------
create or replace view cruises_at_sea (departing_from, arriving_at, num_cruises,
	cruise_list, earliest_arrival, latest_arrival, ship_list) as
select '_', '_', '_', '_', '_', '_', '_';

-- [14] cruises_docked()
-- -----------------------------------------------------------------------------
/* This view describes where cruises that are currently docked are located. */
-- -----------------------------------------------------------------------------
create or replace view cruises_docked (departing_from, num_cruises,
	cruise_list, earliest_departure, latest_departure, ship_list) as 
select '_', '_', '_', '_', '_', '_';

-- [15] people_at_sea()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently at sea are located. */
-- -----------------------------------------------------------------------------
create or replace view people_at_sea (departing_from, arriving_at, num_ships,
	ship_list, cruise_list, earliest_arrival, latest_arrival, num_crew,
	num_passengers, num_people, person_list) as
select '_', '_', '_', '_', '_', '_', '_', '_', '_', '_', '_';

-- [16] people_docked()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently docked are located. */
-- -----------------------------------------------------------------------------
create or replace view people_docked (departing_from, ship_port, port_name,
	city, state, country, num_crew, num_passengers, num_people, person_list) as
with max_sequences as (select max(sequence) as last_sequence, legID 
						from route_path group by legID),
crew_count as (
		select count(cr.personID) as num_crew, cruiseID from 
		crew cr join cruise c on cr.assigned_to = c.cruiseID 
		group by c.cruiseID),
pass_count as (
		select count(pass.personID) as num_p, c.cruiseID from 
		passenger_books pass join cruise c on pass.cruiseID = c.cruiseID 
		group by c.cruiseID)
select departure as departing_from,
po.locationID as ship_port,
sp.port_name,
sp.city,
sp.state,
sp.country,
min(num_crew) as num_crew,
min(num_p) as num_passengers,
min(num_p) + min(num_crew) as num_people,
group_concat(distinct person.personID order by cast(substring(person.personid, 2) as unsigned) separator ',') as person_list
from
cruise c join ship s on c.support_ship_name = s.ship_name and c.support_cruiseline = s.cruiselineID
    join route_path r on c.routeID = r.routeID
    join leg l on r.legID = l.legID
    join ship_port sp on l.departure = sp.portID
    join person_occupies po on po.locationID = sp.locationID
    join max_sequences ms on l.legID = ms.legID
    join crew_count cc on cc.cruiseID = c.cruiseID
    join pass_count pc on pc.cruiseID = c.cruiseID
    left join crew on c.cruiseID = crew.assigned_to
    left join passenger_books pb on c.cruiseID = pb.cruiseID
    left join person on crew.personID = person.personID or pb.personID = person.personID
where c.progress < ms.last_sequence
group by departing_from;
-- [17] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different cruises. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_cruises, cruise_list, port_sequence) as
select '_', '_', '_', '_', '_', '_', '_';

-- [18] alternative_ports()
-- -----------------------------------------------------------------------------
/* This view displays ports that share the same country. */
-- -----------------------------------------------------------------------------
create or replace view alternative_ports (country, num_ports,
	port_code_list, port_name_list) as
select '_', '_', '_', '_';
