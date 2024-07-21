-- [1] add_ship()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ship.  A new ship must be sponsored
by an existing cruiseline, and must have a unique name for that cruiseline. 
A ship must also have a non-zero seat capacity and speed. A ship
might also have other factors depending on it's type, like paddles or some number
of lifeboats.  Finally, a ship must have a new and database-wide unique location
since it will be used to carry passengers. */
-- (cruislineID, ship_name, max_cap, speed, locationID, ship_type, uses_paddles, lifeboats)
-- -----------------------------------------------------------------------------
-- Have existing sponsor
select cruiselineID from cruiseline;
-- Have unique name for sponsor
select ship_name from ship where cruiselineID = 'Ponant';
-- Unique location identifier
select locationID from location;
-- Grab ships
select * from ship;
-- -----------------------------------------------------------------------------
-- Should insert
call add_ship('Carnival', 'Firenze', 4126, 18, 'ship_41', 'ocean_liner', null, 20);
-- Should NOT insert (duplicate locationID)
call add_ship('Disney', 'Magic', 3400, 16, 'ship_23', 'ocean_liner', null, 30);
-- Should insert
call add_ship('Oceania', 'Riptide', 1200, 25, 'ship_28', 'ocean_liner', null, 10);
-- Should insert
call add_ship('MSC', 'Armonia', 3422, 18, 'ship_99', 'ocean_liner', null, 15);
-- Should insert
call add_ship('Ponant', 'Le Mirage', 400, 15, 'ship_56', 'river', false, null);
-- -----------------------------------------------------------------------------

-- [2] add_port() 
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new port.  A new port must have a unique
identifier along with a new and database-wide unique location if it will be used
to support ship arrivals and departures.  A port may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
select portID from ship_port;
select * from location;
select * from ship_port;
-- -----------------------------------------------------------------------------
-- Should insert
call add_port('PDM', 'Port of The Balearic Islands', 'Palma', 'Majorca', 'ESP', 'port_33');
-- Should NOT insert; duplicate locationID
call add_port('PSD', 'Port of San Diego', 'San Diego', 'California', 'USA', 'port_2');
-- -----------------------------------------------------------------------------

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
select personID from person;
select * from location;
select taxID from crew;
select * from person;
select * from passenger;
select * from crew;
-- -----------------------------------------------------------------------------
-- Should insert into crew
call add_person('p61', 'Sabrina', 'Duncan', 'port_1', '366-50-3732', 27, null, null);
-- Should NOT insert; duplicate ID
call add_person('p61', 'Kelly', 'Garrett', 'port_2', null, null, 451, 900);
-- Should NOT insert; invalid location
call add_person('p57', 'Jill', 'Munroe', 'port_100', '401-47-9115', 10, null, null);
-- -----------------------------------------------------------------------------

-- [4] grant_or_revoke_crew_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a crew member's license.  If the license
doesn't exist, it must be created; and, if it already exists, then it must be removed. */
-- -----------------------------------------------------------------------------
select personID from crew;
select * from licenses;
-- -----------------------------------------------------------------------------
-- Add license
call grant_or_revoke_crew_license('p1','river');
-- Remove license
call grant_or_revoke_crew_license('p1','ocean_liner');
-- Should NOT change; not crew
call grant_or_revoke_crew_license('p23','ocean_liner');
-- Should NOT change; invalid personID
call grant_or_revoke_crew_license('p100','river');
-- -----------------------------------------------------------------------------

-- [5] offer_cruise()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new cruise.  The cruise can be defined before
a ship has been assigned for support, but it must have a valid route.  And
the ship, if designated, must not be in use by another cruise.  The cruise
can be started at any valid location along the route except for the final stop,
and it will begin docked.  You must also include when the cruise will
depart along with its cost. */
-- -----------------------------------------------------------------------------
select * from route;
select cruiseID from cruise;
select support_ship_name from cruise;
select max(sequence) from route_path where routeID = 'big_mediterranean_loop';
select * from cruise;
-- -----------------------------------------------------------------------------
call offer_cruise('ca_41', 'americas_three', 'Costa', 'Costa Smeralda', 0, '11:30:00', 400); 
call offer_cruise('oa_43', 'big_mediterranean_loop', 'Oceania', 'Marina', 2, '9:15:00', 100); 
call offer_cruise('cd_19', 'big_mediterranean_loop', 'Cunard', 'Queen Mary 2', 0, '10:00:00', 400); 
call offer_cruise('vo_41', 'americas_three', 'Viking Ocean', 'Viking Orion', 1, '11:30:00', 400);
-- -----------------------------------------------------------------------------