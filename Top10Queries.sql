--- Q1: Delete duplicate data --- 

drop table if exists cars;
create table cars
(
	model_id		int primary key,
	model_name		varchar(100),
	color			varchar(100),
	brand			varchar(100)
);
insert into cars values(1,'Leaf', 'Black', 'Nissan');
insert into cars values(2,'Leaf', 'Black', 'Nissan');
insert into cars values(3,'Model S', 'Black', 'Tesla');
insert into cars values(4,'Model X', 'White', 'Tesla');
insert into cars values(5,'Ioniq 5', 'Black', 'Hyundai');
insert into cars values(6,'Ioniq 5', 'Black', 'Hyundai');
insert into cars values(7,'Ioniq 6', 'White', 'Hyundai');

select * from cars;

select *
from(
	select *, rank() over(partition by model_name, color, brand 
						 order by model_id) as rank
	from cars)
where rank = 1



--- Q1: Delete duplicate data --- 

-- Solution 1:
delete from cars
where model_id not in (select min(model_id)
					  from cars
					  group by model_name, brand);


-- Solution 2:
delete from cars
where ctid in ( select max(ctid)
                from cars
                group by model_name, brand
                having count(1) > 1);

-- Solution 3:
delete from cars
where model_id in (select model_id
                  from (select *
                       , row_number() over(partition by model_name, brand order by model_id) as rn
                       from cars) x
                  where x.rn > 1);


--- Q2: Display highest and lowest salary --- 

drop table if exists employee;
create table employee
(
	id 			int primary key GENERATED ALWAYS AS IDENTITY,
	name 		varchar(100),
	dept_name	varchar(100),
	salary 		int
);
insert into employee values(default, 'Alexander', 'Admin', 6500);
insert into employee values(default, 'Leo', 'Finance', 7000);
insert into employee values(default, 'Robin', 'IT', 2000);
insert into employee values(default, 'Ali', 'IT', 4000);
insert into employee values(default, 'Maria', 'IT', 6000);
insert into employee values(default, 'Alice', 'Admin', 5000);
insert into employee values(default, 'Sebastian', 'HR', 3000);
insert into employee values(default, 'Emma', 'Finance', 4000);
insert into employee values(default, 'John', 'HR', 4500);
insert into employee values(default, 'Kabir', 'IT', 8000);

select * from employee;


--- Q2: Display highest and lowest salary --- 

-- Solution:
select * 
, max(salary) over(partition by dept_name order by salary desc) as highest_sal
, min(salary) over(partition by dept_name order by salary desc
                  range between unbounded preceding and unbounded following) as lowest_sal
, min(salary) over(partition by dept_name order by salary asc) as lowest_sal_optb
from employee;


--- **************************************************************************************** ---               
--- Q3 : Find actual distance --- 

drop table if exists car_travels;
create table car_travels
(
    cars                    varchar(40),
    days                    varchar(10),
    cumulative_distance     int
);
insert into car_travels values ('Car1', 'Day1', 50);
insert into car_travels values ('Car1', 'Day2', 100);
insert into car_travels values ('Car1', 'Day3', 200);
insert into car_travels values ('Car2', 'Day1', 0);
insert into car_travels values ('Car3', 'Day1', 0);
insert into car_travels values ('Car3', 'Day2', 50);
insert into car_travels values ('Car3', 'Day3', 50);
insert into car_travels values ('Car3', 'Day4', 100);

select * from car_travels;


--- **************************************************************************************** ---               

--- Q3 : Find actual distance --- 

-- Solution:
select *
,lag(cumulative_distance, 1, 0) over(partition by cars order by days)
, cumulative_distance - lag(cumulative_distance, 1, 0) over(partition by cars order by days) as distance_travelled
from car_travels;


--- **************************************************************************************** ---   

--- Q4 : Convert the given input to expected output --- 

drop table if exists src_dest_distance ;
create table src_dest_distance
(
    source          varchar(20),
    destination     varchar(20),
    distance        int
);
insert into src_dest_distance values ('Bangalore', 'Hyderbad', 400);
insert into src_dest_distance values ('Hyderbad', 'Bangalore', 400);
insert into src_dest_distance values ('Mumbai', 'Delhi', 400);
insert into src_dest_distance values ('Delhi', 'Mumbai', 400);
insert into src_dest_distance values ('Chennai', 'Pune', 400);
insert into src_dest_distance values ('Pune', 'Chennai', 400);

select * from src_dest_distance;




--- Q4 : Convert the given input to expected output. The irigin-destination should not repeat --- 

-- Solution:
with cte as
    (select *
    , row_number() over() as rn
    from src_dest_distance)
select t1.source, t1.destination, t1.distance
from cte t1
join cte t2
        on t1.rn < t2.rn
        and t1.source = t2.destination
        and t1.destination = t2.source;

--- **************************************************************************************** ---               


--- Q5 : Ungroup the given input data --- 

drop table if exists travel_items;
create table travel_items
(
	id              int,
	item_name       varchar(50),
	total_count     int
);
insert into travel_items values (1, 'Water Bottle', 2);
insert into travel_items values (2, 'Tent', 1);
insert into travel_items values (3, 'Apple', 4);

select *
from travel_items

--- **************************************************************************************** ---               


--- Q5 : Ungroup the given input data --- 

-- Solution:
with recursive cte as
    (select id, item_name, total_count, 1 as level
    from travel_items
    union all
    select cte.id, cte.item_name, cte.total_count - 1, level+1 as level
    from cte
    join travel_items t on t.item_name = cte.item_name and t.id = cte.id
    where cte.total_count > 1
    )
select id, item_name
from cte
order by 1;


--- **************************************************************************************** ---               

--- Q6 : IPL Matches --- 

drop table if exists teams;
create table teams
    (
        team_code       varchar(10),
        team_name       varchar(40)
    );

insert into teams values ('RCB', 'Royal Challengers Bangalore');
insert into teams values ('MI', 'Mumbai Indians');
insert into teams values ('CSK', 'Chennai Super Kings');
insert into teams values ('DC', 'Delhi Capitals');
insert into teams values ('RR', 'Rajasthan Royals');
insert into teams values ('SRH', 'Sunrisers Hyderbad');
insert into teams values ('PBKS', 'Punjab Kings');
insert into teams values ('KKR', 'Kolkata Knight Riders');
insert into teams values ('GT', 'Gujarat Titans');
insert into teams values ('LSG', 'Lucknow Super Giants');
commit;

-- 1) Write an sql query such that each team play with every other team just once. 

select *
from teams;

--- Q6 : IPL Matches --- 

-- Solution for 1: Each team plays with every other team JUST ONCE.
WITH matches AS
    (SELECT row_number() over(order by team_name) AS id, t.*
     FROM teams t)
SELECT team.team_name AS team, opponent.team_name AS opponent
FROM matches team
JOIN matches opponent ON team.id < opponent.id
ORDER BY team;


--- **************************************************************************************** ---               


--- Q10: Pizza Delivery Status --- 

drop table if exists cust_orders;
create table cust_orders
(
cust_name   varchar(50),
order_id    varchar(10),
status      varchar(50)
);

insert into cust_orders values ('John', 'J1', 'DELIVERED');
insert into cust_orders values ('John', 'J2', 'DELIVERED');
insert into cust_orders values ('David', 'D1', 'SUBMITTED');
insert into cust_orders values ('David', 'D2', 'DELIVERED'); -- This record is missing in question
insert into cust_orders values ('David', 'D3', 'CREATED');
insert into cust_orders values ('Smith', 'S1', 'SUBMITTED');
insert into cust_orders values ('Krish', 'K1', 'CREATED');
commit;

select *
from cust_orders;


--- Q10: Pizza Delivery Status --- 

-- Pizza Delivery Status	
-- A pizza company is taking orders from customers, and each pizza ordered is added to their database as a separate order.	
-- Each order has an associated status, "CREATED or SUBMITTED or DELIVERED'. 	
-- An order's Final_ Status is calculated based on status as follows:	
-- 	1. When all orders for a customer have a status of DELIVERED, that customer's order has a Final_Status of COMPLETED.
-- 	2. If a customer has some orders that are not DELIVERED and some orders that are DELIVERED, the Final_ Status is IN PROGRESS.
-- 	3. If all of a customer's orders are SUBMITTED, the Final_Status is AWAITING PROGRESS.
-- 	4. Otherwise, the Final Status is AWAITING SUBMISSION.
	
-- Write a query to report the customer_name and Final_Status of each customer's arder. Order the results by customer	
-- name.	


-- Solution 
select distinct cust_name as customer_name, 'COMPLETED' as status
from cust_orders D
where D.status = 'DELIVERED'
and not exists (select 1 from cust_orders d2
                where d2.cust_name=d.cust_name
                and d2.status in ('SUBMITTED','CREATED'))
    union
select distinct cust_name as customer_name, 'IN PROGRESS' as status
from cust_orders D
where D.status = 'DELIVERED'
and  exists (select 1 from cust_orders d2
                where d2.cust_name=d.cust_name
                and d2.status in ('SUBMITTED','CREATED'))
    union
select distinct cust_name as customer_name, 'AWAITING PROGRESS' as status
from cust_orders D
where D.status = 'SUBMITTED'
and not exists (select 1 from cust_orders d2
                where d2.cust_name=d.cust_name
                and d2.status in ('DELIVERED'))
    union
select distinct cust_name as customer_name, 'AWAITING SUBMISSION' as status
from cust_orders D
where D.status = 'CREATED'
and not exists (select 1 from cust_orders d2
                where d2.cust_name=d.cust_name
                and d2.status in ('DELIVERED','SUBMITTED'));




