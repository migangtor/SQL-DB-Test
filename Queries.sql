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






