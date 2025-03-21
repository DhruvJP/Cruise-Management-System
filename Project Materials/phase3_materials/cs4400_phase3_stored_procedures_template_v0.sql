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

    -- Check to see if the ship can move and house people as well as having a unique locationID
    if ip_max_capacity > 0 and ip_speed > 0 and ip_locationID not in (select locationID from location) then
        -- Check for present cruiselineID and a unique ship name to the cruiseline
        if ip_cruiselineID in (select cruiselineID from cruiseline)
            and ip_ship_name not in (select ship_name from ship where cruiselineID = ip_cruiselineID) then

            -- Add location as a possible referential key
            insert into location (locationID) values (ip_locationID);
            -- Insert new ship values
            insert into ship (cruiselineID, ship_name, max_capacity, speed, locationID, ship_type, uses_paddles, lifeboats)
                values (ip_cruiselineID, ip_ship_name, ip_max_capacity, ip_speed, ip_locationID, ip_ship_type, ip_uses_paddles, ip_lifeboats);
        end if;
    end if;

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

    -- Check that portID and locationID are unique (locationID can be null)
    if ip_portID not in (select portID from ship_port) and (ip_locationID not in (select locationID from location) or ip_locationID is null) then
        -- Add locationID if one is provided
        if ip_locationID is not null then
            insert into location (locationID) values (ip_locationID);
        end if;
        -- Create new entry
        insert into ship_port (portID, port_name, city, state, country, locationID) values (ip_portID, ip_port_name, ip_city, ip_state, ip_country, ip_locationID);
    end if;

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

    -- Check that the person has a unique identifier and that their location is valid
    -- Also ensures they have a first name
    if ip_personID not in (select personID from person)
        and ip_locationID in (select locationID from location) and ip_first_name is not null then

        -- Different inserts depending on if they are a passenger or crew
        -- Only crew will / must have non null taxID
        if ip_taxID is null then
            -- Passenger
            insert into person (personID, first_name, last_name) values (ip_personID, ip_first_name, ip_last_name);
            insert into passenger (personID, miles, funds) values (ip_personID, ip_miles, ip_funds);
            insert into person_occupies (personID, locationID) values (ip_personID, ip_locationID);
        else
            -- Crew (taxID must be unique)
            -- assigned_to will default to null
            if ip_taxID not in (select taxID from crew) then
                insert into person (personID, first_name, last_name) values (ip_personID, ip_first_name, ip_last_name);
                insert into crew (personID, taxID, experience) values (ip_personID, ip_taxID, ip_experience);
                insert into person_occupies (personID, locationID) values (ip_personID, ip_locationID);
            end if;
        end if;
    end if;

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

    -- This person must be a crew member to perform operations for them
    if ip_personID in (select personID from crew) then
        -- Check to see if they have the license
        if ip_license in (select license from licenses where personID = ip_personID) then
            -- There are no references to the license, so it's safe to delete
            delete from licenses where personID = ip_personID and license = ip_license;
        else
            insert into licenses (personID, license) values (ip_personID, ip_license);
        end if;
    end if;

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

    -- Check for valid route
    if ip_routeID in (select routeID from route) and ip_cruiseID not in (select cruiseID from cruise) then
        -- Check to see if assigned ship is not in use
        if ip_support_ship_name not in (select support_ship_name from cruise) or ip_support_ship_name is null then
            -- Update cruiseline table if new cruiselineID is used
            if ip_support_cruiseline not in (select cruiselineID from cruiseline) then
                insert into cruisline (cruiselineID) values (ip_cruiselineID);
            end if;
            -- Ensure we have a valid progress point
            -- progress should be between 0 and max(sequence) - 1
            if ip_progress between 0 and ((select max(sequence) from route_path where routeID = ip_routeID) - 1) then
                insert into cruise (cruiseID, routeID, support_cruiseline, support_ship_name, progress, ship_status, next_time, cost)
                    values (ip_cruiseID, ip_routeID, ip_support_cruiseline, ip_support_ship_name, ip_progress, 'docked', ip_next_time, ip_cost);
            end if;
        end if;
    end if;

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
begin
    declare current_progress integer;
    declare rID varchar(50);
    declare current_legID varchar(50);
    declare arrival_port char(3);
    declare arrival_locationID varchar(50);
    declare ship_name varchar(50);
    declare cruiselineID varchar(50);

    select progress, routeID, support_ship_name, support_cruiseline
    into current_progress, rID, ship_name, cruiselineID
    from cruise
    where cruiseID = ip_cruiseID;
    select legID into current_legID
    from route_path
    where routeID = rID and sequence = current_progress;
    select arrival into arrival_port
    from leg
    where legID = current_legID;
    select locationID into arrival_locationID
    from ship_port
    where portID = arrival_port;
    update cruise
    set ship_status = 'docked',
        next_time = addtime(next_time, '08:00:00')
    where cruiseID = ip_cruiseID;
    update crew
    set experience = experience + 1
    where assigned_to = ip_cruiseID;
    update passenger p
    join passenger_books pb on p.personID = pb.personID
    set p.miles = p.miles + (select distance from leg where legID = current_legID)
    where pb.cruiseID = ip_cruiseID;
    delete from person_occupies
    where locationID = arrival_locationID
    and personID in (
        select personID from passenger_books where cruiseID = ip_cruiseID
        union
        select personID from crew where assigned_to = ip_cruiseID
    );
    insert into person_occupies (personID, locationID)
    select personID, arrival_locationID
    from (
        select personID from passenger_books where cruiseID = ip_cruiseID
        union
        select personID from crew where assigned_to = ip_cruiseID
    ) as people;
    insert into person_occupies (personID, locationID)
    select personID, (select locationID from ship where ship_name = ship_name and cruiselineID = cruiselineID)
    from (
        select personID from passenger_books where cruiseID = ip_cruiseID
        union
        select personID from crew where assigned_to = ip_cruiseID
    ) as people;
    update ship
    set locationID = arrival_locationID
    where cruiselineID = cruiselineID and ship_name = ship_name;
    update cruise
    set progress = current_progress + 1
    where cruiseID = ip_cruiseID;
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
begin
    declare current_progress integer;
    declare routeID varchar(50);
    declare current_legID varchar(50);
    declare departure_port char(3);
    declare arrival_port char(3);
    declare arrival_locationID varchar(50);
    declare departure_locationID varchar(50);
    declare ship_name varchar(50);
    declare cruiselineID varchar(50);
    declare speed float;
    declare distance integer;
    declare travel_time time;
    declare num_people_on_board integer;
    declare num_people_expected integer;
    select progress, routeID, support_ship_name, support_cruiseline
    into current_progress, routeID, ship_name, cruiselineID
    from cruise
    where cruiseID = ip_cruiseID
    limit 1;
    select legID into current_legID
    from route_path
    where routeID = routeID and sequence = current_progress
    limit 1;
    select departure, arrival into departure_port, arrival_port
    from leg
    where legID = current_legID
    limit 1;
    select locationID into departure_locationID
    from ship_port
    where portID = departure_port
    limit 1;
    select locationID into arrival_locationID
    from ship_port
    where portID = arrival_port
    limit 1;
    select speed into speed
    from ship
    where cruiselineID = cruiselineID and ship_name = ship_name
    limit 1;
    select distance into distance
    from leg
    where legID = current_legID
    limit 1;
    set travel_time = leg_time(distance, speed);
    select count(*) into num_people_expected
    from (
        select personID from passenger_books where cruiseID = ip_cruiseID
        union all
        select personID from crew where assigned_to = ip_cruiseID
    ) as expected;
    select count(*) into num_people_on_board
    from person_occupies
    where locationID = departure_locationID
    and personID in (
        select personID from passenger_books where cruiseID = ip_cruiseID
        union all
        select personID from crew where assigned_to = ip_cruiseID
    );
    if num_people_on_board <> num_people_expected then
        update cruise
        set next_time = addtime(next_time, '00:30:00')
        where cruiseID = ip_cruiseID;
    else
        update cruise
        set ship_status = 'sailing',
            progress = progress + 1,
            next_time = addtime(current_time(), travel_time)
        where cruiseID = ip_cruiseID;
        update person_occupies
        set locationID = (select locationID from ship where cruiselineID = cruiselineID and ship_name = ship_name limit 1)
        where locationID = departure_locationID
        and personID in (
            select personID from passenger_books where cruiseID = ip_cruiseID
            union all
            select personID from crew where assigned_to = ip_cruiseID
        );
        delete from person_occupies
        where locationID = departure_locationID
        and personID in (
            select personID from passenger_books where cruiseID = ip_cruiseID
            union all
            select personID from crew where assigned_to = ip_cruiseID
        );
    end if;
end //
delimiter ;

-- [8] person_boards()
-- -----------------------------------------------------------------------------
/* 
1. This stored procedure updates the location for people, (crew and passengers), 
2. getting on a in-progress cruise at its current port.
3. The person must be at the same port as the cruise,
4. and that person must either have booked that cruise as a passenger
 or been assigned to it as a crew member.
5. The person's location cannot already be assigned to the ship
they are boarding. 

6. After running the procedure, the person will still be assigned to the port location, 
but they will also be assigned to the ship location. */
-- -----------------------------------------------------------------------------
drop procedure if exists person_boards;
delimiter //
create procedure person_boards (in ip_personID varchar(50), in ip_cruiseID varchar(50))
sp_main: begin
	-- declare inProgress int default 0;
    -- declare cruisePortLocation varchar(50);
    -- declare personPortLocation varchar(50);
	declare shipLocID varchar(50);


    -- 1. null check
    if (ip_personID is null or ip_personID = '') or (ip_cruiseID is null or ip_cruiseID = '')
    then leave sp_main;
	end if;
    /*
    -- check if person or cruise params are valid.
    if ((ip_personID) not in (select personID from person)) or ((ip_cruiseID) not in (select cruiseID from cruise))
    then leave sp_main; end if;
    
	-- 2. person must either have booked that cruise as a passenger
	-- or been assigned to it as a crew member.
    -- if it fails this conditional then we assume that they
    -- haven't booked as a passenger or aren't apart of crew
    -- person must book the cruise specified as they can
    -- have same personID but book different cruises
    if (ip_personID, ip_cruiseID) not in
		(select personID, cruiseID
        from passenger_books)
		or (ip_personID, ip_cruiseID)  not in
			(select personID, assigned_to 
            from crew)
	then leave sp_main;
    end if;

    -- 3. check if its an in progress cruise
    -- obtain progress from cruise to check conditional.
    select progress into inProgress
    from cruise
    where cruiseID = ip_cruiseID;
    
    if (inProgress is null) or (inProgress = '') or 
    (inProgress = 
		(select max(sequence) 
		from cruise join route_path
        on cruise.routeID = route_path.routeID
        group by cruise.routeID
        having cruise.cruiseID = ip_cruiseID))
	-- leave if max sequence is reached.
    then leave sp_main;
    end if;
    
    -- 3. get the port/locationID of the cruise
    -- and check if person's locationID is the same
    select ship_port.locationID into cruisePortLocation 
    from cruise join route_path
    on cruise.routeID = route_path.routeID
    join leg on route_path.legID = leg.legID
    join ship_port on ((leg.departure = ship_port.portID) or (leg.arrival = ship_port.portID))
    where cruise.cruiseID = ip_cruiseID;
    
    -- 3A. obtain person location port given
    -- the location ID parameter
    select locationID into personPortLocation
    from person_occupies
    where person_occupies.personID = ip_personID
    and person_occupies.locationID like 'port_%';
    
    -- 3B. conditional to check if person and
    -- cruise are at the same port
	-- otherwise we assume if it fails the condition
    -- they are at the same port, used '=' to give exact
    -- depiction/result.
    if cruisePortLocation != personPortLocation
    then leave sp_main;
    end if;
    
    
    -- checking if person isn't already assigned to ship
	select locationID into personPortLocation
    from person_occupies
    where person_occupies.personID = ip_personID
    and person_occupies.locationID like 'ship_%'; */
    
    -- obtains ship.locationID to check if person isn't already assigned
    -- to the ship
    select ship.locationID into shipLocID
    from cruise join ship
    on cruise.support_cruiseline = ship.cruiselineID
    where cruise.cruiseID = ip_cruiseID;
    
    -- if personPortLocation = shipLocID
    -- then leave sp_main;
    -- end if;
    
    
    -- 5. The person's location cannot already
    -- be assigned to the ship they are boarding. 
            
    
    -- conditional to check if the person is
    -- already assigned to the ship they are trying to
    -- board, if thats the case then leave sp_main;

    
    -- 6. add the person to the ship location
    /*select ship.locationID into shipLocID
    from ship join person_occupies
    on person_occupies.locationID = ship.locationID
    where person_occupies.personID = ip_personID;
*/

    -- Add the person to the ship location
    if exists (select locationID from person_occupies
    where person_occupies.personID = ip_personID and person_occupies.locationID like 'ship_%')
    then
    update person_occupies
    set locationID = shipLocID
    where person_occupies.personID = ip_personID
    and person_occupies.locationID like 'ship_%';
    
    else insert into person_occupies (personID, locationID)
    values (ip_personID, shipLocID);
	end if;

end //
delimiter ;


-- [9] person_disembarks()
-- -----------------------------------------------------------------------------
/* 
1. This stored procedure updates the location for people, (crew and passengers), 
getting off a cruise at its current port.
2. The person must be on the ship supporting the cruise, 
and the cruise must be docked at a port. 
3. The person should no longer be assigned to the ship location,
and they will only be assigned to the port location. */
-- -----------------------------------------------------------------------------
drop procedure if exists person_disembarks;
delimiter //
create procedure person_disembarks (in ip_personID varchar(50), in ip_cruiseID varchar(50))
sp_main: begin
	declare shipLocVal varchar(50);

    -- Check if input parameters are valid
    if (ip_personID is null or ip_personID = '') or (ip_cruiseID is null or ip_cruiseID = '')
    then leave sp_main;
	end if;
    
    -- 1. person must be on the ship supporting the cruise
	/* select ship.locationID into shipLocID
    from cruise join ship
    on cruise.support_cruiseline = ship.cruiselineID
    where cruise.cruiseID = ip_cruiseID; */ 
    

    select ship.locationID into shipLocVal
    from cruise join ship
    on cruise.support_ship_name = ship.ship_name
    join person_occupies on person_occupies.personID = ip_personID
    where cruise.cruiseID = ip_cruiseID and cruise.ship_status like 'docked'
    group by locationID;
    

	if exists (select locationID from person_occupies
    where person_occupies.personID = ip_personID and person_occupies.locationID like 'ship_%')
    then
    -- Remove the person from the ship location
    delete from person_occupies
    where personID = ip_personID and locationID = shipLocVal;
    end if;

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
select departure as 'departing_from', arrival as 'arriving_at', count(*) as 'num_cruises',
    group_concat(cruiseID separator ', ') as 'cruise_list', min(next_time) as 'earliest_arrival',
    max(next_time) as 'latest_arrival', group_concat(locationID separator ', ') as 'ship_list'

    from cruise inner join route_path on progress = sequence and cruise.routeID = route_path.routeID
        natural join leg
        inner join ship on support_ship_name = ship_name
    where ship_status = 'sailing'
    group by legID;

-- [14] cruises_docked()
-- -----------------------------------------------------------------------------
/* This view describes where cruises that are currently docked are located. */
-- -----------------------------------------------------------------------------
create or replace view cruises_docked (departing_from, num_cruises,
	cruise_list, earliest_departure, latest_departure, ship_list) as 
select departure as 'departing_from', count(*) as 'num_cruises',
    group_concat(cruiseID separator ', ') as 'cruise_list', min(next_time) as 'earliest_arrival',
    max(next_time) as 'latest_arrival', group_concat(locationID separator ', ') as 'ship_list'

    -- Use a plus 1 to remove cruises that have already reached their end destination
    from cruise inner join route_path on progress + 1 = sequence and cruise.routeID = route_path.routeID
        natural join leg
        inner join ship on support_ship_name = ship_name
        where ship_status = 'docked'
    group by departure;

-- [15] people_at_sea()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently at sea are located. */
-- -----------------------------------------------------------------------------
create or replace view people_at_sea (departing_from, arriving_at, num_ships,
	ship_list, cruise_list, earliest_arrival, latest_arrival, num_crew,
	num_passengers, num_people, person_list) as
select
	(leg.departure) as departing_from,
	(leg.arrival) as arriving_at,
    count(distinct(cruise.cruiseID)) as num_ships,
    group_concat(distinct ship.locationID order by ship.locationID separator '') as ship_list,
    group_concat(distinct cruise.cruiseID order by cruise.cruiseID separator '') as cruise_list,
    min(distinct(cruise.next_time)) as earliest_arrival,
    max(distinct(cruise.next_time)) as latest_arrival,
    count(distinct(crew.personID)) as num_crew,
    count(distinct(passenger_books.personID)) as num_passengers,
    count(distinct(person.personID))as num_people,
    group_concat(distinct person.personID order by cast(substring(person.personid, 2) as unsigned) separator ',') as person_list  
from cruise join route_path
on cruise.routeID = route_path.routeID
join leg on route_path.legID = leg.legID
join ship on (cruise.support_ship_name = ship.ship_name)
join crew on cruise.cruiseID = crew.assigned_to
join passenger_books on cruise.cruiseID = passenger_books.cruiseID
join person on ((crew.personID = person.personID) or (passenger_books.personID = person.personID))
where cruise.ship_status like 'sailing' and (route_path.sequence = cruise.progress) 
group by leg.departure, leg.arrival;

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
select
	cruise.routeID, 
	count(distinct(route_path.legID)) as num_legs,
	group_concat(distinct(route_path.legID) order by route_path.sequence asc separator ',') as leg_sequence,
    round(sum(distinct(leg.distance)), 0) as route_length,
    count(distinct(cruiseID)) as num_cruises,
    group_concat(distinct(cruise.cruiseID) order by cruise.cruiseID separator ',') as cruise_list,
    group_concat(distinct(concat(leg.departure, ' -> ', leg.arrival)) order by route_path.sequence separator ',') as port_sequence
from cruise join route_path
on cruise.routeID = route_path.routeID
join leg on route_path.legID = leg.legID
join ship_port on ((leg.departure = ship_port.portID) or (leg.arrival = ship_port.portID))
group by cruise.routeID;

-- [18] alternative_ports()
-- -----------------------------------------------------------------------------
/* This view displays ports that share the same country. */
-- -----------------------------------------------------------------------------
create or replace view alternative_ports (country, num_ports, port_code_list, port_name_list) as
select country, count(*) as num_ports, group_concat(portID order by portID separator ', ') as port_code_list, group_concat(port_name order by portID separator ', ') as port_name_list
from ship_port
group by country;
