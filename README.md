# How to solve several SQL queries that are important for job interviews. 

The first query is to extract duplicate data from a table, which can be accomplished using the group by command.

The second query is to display the highest and lowest salary corresponding to each employee record, which can be solved by using window functions to partition the data by department and apply aggregate functions. 

he third query involves finding the actual distance traveled by a car on each day based on a given input table with cumulative distances, which can be done using the lag window function. 

The fourth query involves deriving the expected output from a table that has redundant data, which can be solved by using the self-join concept and a row number window function. 

The fifth query involves ungrouping input data using recursive SQL functionalities.

The sixth query involves deriving IPL matches, which can be accomplished using a self-join with a unique identifier and ensuring that each team plays with the other team only once. 

The seventh query involves calculating the output columns of a SQL table and the data types, which can be accomplished by flattening the columns of the table and applying the Cast() function to convert data types. 

The eighth query involves finding the hierarchy of employees under a given manager, which can be accomplished using recursive SQL queries. 

The ninth query involves finding the difference in average sales for each month between two years, which can be done using self-joins and grouping by year and month. 

Finally, the last query involves calculating the delivery status of a Pizza company, which depends on four rules and can be accomplished by writing a query that checks the status of the order and returns the appropriate final status.