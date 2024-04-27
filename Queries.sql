select *
from employee;

-- Query 1
-- Select min/max salary by employee in each department

SELECT *,
max(salary) OVER(PARTITION BY dept_name) as max_salary,
min(salary) OVER(PARTITION BY dept_name ORDER BY Salary ASC) as min_salary
FROM Employee


-- Fetch the first 2 employees from each department in the company
SELECT *
FROM (
	SELECT *,
	row_number() OVER(PARTITION BY dept_name ORDER BY salary) as row_num
	FROM EMPLOYEE) as rn
WHERE rn.row_num < 3


-- fetch the top 3 employees in each department earning the max salary

SELECT *,
rank() OVER(PARTITION BY dept_name ORDER BY salary) as rank_salary,
dense_rank() OVER(PARTITION BY dept_name ORDER BY salary) as d_rank_salary,
row_number() OVER(PARTITION BY dept_name ORDER BY salary) as row_num
FROM EMPLOYEE


SELECT *
FROM
	(SELECT *,
	rank() OVER(PARTITION BY dept_name ORDER BY salary) as rank_salary,
	dense_rank() OVER(PARTITION BY dept_name ORDER BY salary) as d_rank_salary
	FROM EMPLOYEE) as rn
WHERE rn.rank_salary <=3 

-- Running total, count, average and quartile
SELECT *,
SUM(salary) OVER(ORDER BY emp_id) as running_tot,
COUNT(salary) OVER(ORDER BY emp_id) as running_count,
AVG(salary) OVER(ORDER BY emp_id) as running_avg,
NTILE(4) OVER(ORDER BY emp_id) as quartile
FROM EMPLOYEE;

-- Lag and Lead

SELECT *,
LAG(salary) OVER (PARTITION BY dept_name) as lag,
LAG(salary,2) OVER (PARTITION BY dept_name) as lag2,
LAG(salary,2,0) OVER (PARTITION BY dept_name) as lag3,
LEAD(salary) OVER (PARTITION BY dept_name) as lead
FROM EMPLOYEE


-- First and Last Value

SELECT *,
first_value(emp_name) over (partition by dept_name order by salary) as least_paid,
first_value(emp_name) over (partition by dept_name order by salary desc) as highest_paid
FROM EMPLOYEE



SELECT *,
--first_value(emp_name) over (partition by dept_name order by salary) as least_paid,
last_value(emp_name) over (partition by dept_name order by salary desc
						  range between unbounded preceding and current row
						  ) as highest_paid
FROM EMPLOYEE

-- fetch a query to display if the salary of an employee is higher, lower
-- or equal to the previous employee


SELECT *,
LAG(salary,1,0) OVER (PARTITION BY dept_name ORDER BY emp_id) as prev_emp_salary,
CASE 
	WHEN salary > LAG(salary,1,0) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN 'High'
	WHEN salary = LAG(salary,1,0) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN 'Same'
	WHEN salary < LAG(salary,1,0) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN 'Low'
END AS test
FROM EMPLOYEE











