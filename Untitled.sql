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
	dept 		varchar(100),
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
, max(salary) over(partition by dept order by salary desc) as highest_sal
, min(salary) over(partition by dept order by salary desc
                  range between unbounded preceding and unbounded following) as lowest_sal
, min(salary) over(partition by dept order by salary asc) as lowest_sal_optb

from employee;


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




