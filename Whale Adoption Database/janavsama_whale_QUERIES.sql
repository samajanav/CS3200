-- Load WHALE_SETUP.sql into a ROOT connection. Run the script.
-- This will generate a database called whale_adption and populate
-- the database with data.

-- Write queries for each of the questions below.
-- Take screen shots of your output for each query.  Create a PDF file
-- that consolidates your outputs for each query. 

-- Submissions using ChatGPT in whole or in part will receive a ZERO.
-- Solutions copied from other students or the internet in whole or in part will receive a ZERO
-- for all parties involved.

use whale_adoption;

-- 1. 
-- How much money has been collected from adoption fees?

select sum(charge_amt) from adoption;

-- 2. 
-- Count how many sightings there are for male whales and for female whales.
-- Use aliases for aggregation functions.

select whale.gender, count(sighting.whale_id) as total_sightings
from whale
inner join sighting on whale.whale_id = sighting.whale_id
group by whale.gender;

-- 3. 
-- For each adoption, list the name of the whale, the last name of the adopting user,
-- the adoption charge amount, and the type of credit card used for the adoption.

select 
    whale.name as whale_name,
    user.user_lastname as adopter_last_name,
    adoption.charge_amt as adoption_charge,
    creditcard.type as credit_card_type
from adoption
inner join whale on adoption.whale_id = whale.whale_id
inner join user on adoption.user_id = user.user_id
inner join creditcard on user.user_id = creditcard.user_id;

-- 4. 
-- How many total sightings were there for whales that were also adopted.
-- For example, if A was sighted 2 times, B was sighted 3 times, and C
-- was sighted 4 times, but only A and B were adopted, the query
-- should return 5.

select count(sighting.whale_id) as total_adopted_sightings
from whale
inner join adoption on whale.whale_id = adoption.whale_id
inner join sighting on whale.whale_id = sighting.whale_id;

-- 5. 
-- The YEAR function extracts the year from a date.
-- List all users who adopted a whale in 2021.
-- Only list each user once, even if they adopted more than one whale.
-- List their first and last name and all address-related fields
-- Output the list in alphabetical order by last name.
-- The New England Aquarium plans to send these users an end-of-year holiday thank you!

select 
    user.user_firstname,
    user.user_lastname,
    user.address,
    user.city,
    user.state,
    user.country,
    user.zipcode
from user
inner join adoption on user.user_id = adoption.user_id
where year(adoption.dt) = 2021
group by user.user_id
order by user.user_lastname asc;

-- 6. 
-- How much did each user spend on adoption fees?
-- Include users that didn't spend anything
-- If they didn't spend anything, show "0" rather than "null"
-- Sort users from biggest spender to smallest.
-- In case of a tie, sort by the user's last name

select 
    user.user_firstname,
    user.user_lastname,
    if(sum(adoption.charge_amt) is null, 0, sum(adoption.charge_amt)) as total_spent
from user
left join adoption on user.user_id = adoption.user_id
group by user.user_id
order by 
    total_spent desc,
    user.user_lastname asc;

-- 7 
-- Overall, ON AVERAGE, how many times was each whale sighted?
-- Factor into your average those whales that were never sighted.
-- I'm looking for a single number.
-- For example, if I had two whales and one was sighted 3 times and the other 0 times
-- that would be 1.5 sightings per whale.

select 
    sum(sighting_count) / count(*) as avg_sightings_per_whale
from (
    select 
        whale.whale_id,
        count(sighting.whale_id) as sighting_count
    from whale
    left join sighting on whale.whale_id = sighting.whale_id
    group by whale.whale_id
    
) as whale_sightings;


-- 8 
-- The MONTHNAME function takes a date and returns the name of the month (January...December).
-- The MONTH function takes a date and returns the NUMBER of month 1, 2, ..., 12.
-- How many whales were born in each month?
-- List the name of the month and the number of births.
--  You may ignore months that have no births, BUT, months should be listed in calendar order!
-- Filter out whales and counts for when the date of birth is unknown
-- Note this may not be scientifically accurate!

select 
    dob as birth_date,
    count(whale_id) as num_births
from whale
where dob is not null
group by dob
order by dob;


-- 9 
-- For each research team, list the name and affiliation of the team,
-- The principle investigator (PI) last name,
-- The number of sightings, and the number of  sightings where the
-- identity of the whale was certain.
-- Include research teams that made no sightings
-- Zero counts should show "0" not "null"
-- Assign column aliases where appropriate
-- Sort output from most total sightings to least total sightings.

select 
    researchteam.name,
    researchteam.affiliation,
    researchteam.pi_lastname,
    count(sighting.researchteam_id) as total_sightings,
    count(sighting.is_certain_ident = 1 or null) as certain_sightings
from researchteam
left join sighting on researchteam.researchteam_id = sighting.researchteam_id
group by researchteam.researchteam_id
order by total_sightings desc;

-- 10. 
-- What whales were sighted more than once?
-- List their names and the number of times they were sighted
-- order from most sighted to least sighted.
-- In cases of a tie, order alphabetically by the name of the whale

select 
    whale.name as whale_name,
    count(sighting.whale_id) as sighting_count
from whale
inner join sighting on whale.whale_id = sighting.whale_id
group by whale.whale_id
having sighting_count > 1
order by 
    sighting_count desc,
    whale_name asc;

-- 11
-- How many times was each whale sighted and adopted?
-- Include whales that were never sighted or never adopted.
-- Make sure the total number of adoptions and sightings 
-- matches what is in the adoptions / sightings table respectively.
-- Zero adoptions or sightings should be output as "0" not null. 
-- Order your output by descending number of sightings, then descending
-- number of adoptions, then whale name.

select 
    whale.name as whale_name,
    COUNT(sighting.whale_id) as total_sightings,
    COUNT(adoption.whale_id) as total_adoptions
from whale
left join sighting on whale.whale_id = sighting.whale_id
left join adoption on whale.whale_id = adoption.whale_id
group by whale.whale_id
order BY 
    total_sightings desc,
    total_adoptions desc,
    whale_name asc;

-- 12. 
-- List the name and gender of every whale along with the name and gender of that whale's mother.
-- Include whales that have no known mother.
-- Add column aliases where appropriate

select 
    child.name as whale_name,
    child.gender as whale_gender,
    mother.name as mother_name,
    mother.gender as mother_gender
from whale as child
left join whale as mother on child.mother_id = mother.whale_id;

-- 13. 
-- If you examine the sighting table you will notice that 1 whale was sighted four times, 3 whales
-- were sighted twice, and two whales were sighted only once.  Four whales have not been sighted!
-- Write a query that generates these
-- statistics automatically.   We want to know how many whales were sighted k times for different
-- values of k.   You only need to include k values that apply.
-- I'm looking for a table something like this:
-- 		N	 k
-- 		1	 4
-- 		3    2
-- 		2    1
--      4    0

select 
    count(sighting_count), 
    sighting_count as k
from (
    select 
        whale.whale_id,
        count(sighting.whale_id) as sighting_count
    from whale
    left join sighting on whale.whale_id = sighting.whale_id
    group by whale.whale_id
) 	as whale_sightings
	group by sighting_count
	order by k desc; 
    

-- 14. 
-- Which North Atlantic Right Whales should be saved?
-- Select all the whales. Show all their attributes.
-- Don't overthink it!  ;-)

select * from whale;

