**SQL Concepts and Learning Involved in LeetCode SQL 50 Problem set**

1. **ROUND(x, y)**
   - Rounds the value `x` to `y` number of decimal places.
   - Example: `ROUND(123.4567, 2)` results in `123.46`.
   - Useful for formatting numeric output, especially in reporting.

2. **CAST(x AS y)**
   - Converts a value from one data type to another.
   - Example: `CAST(123 AS FLOAT)` or `CAST('2023-01-01' AS DATE)`.
   - Essential when combining data types or performing arithmetic operations.

3. **Convert Integer to Float for Calculations**
   - Multiplying an integer by `1.0` or using `CAST` ensures decimal precision.
   - Example: `ROUND(AVG(e.age * 1.0), 0)` avoids integer division.

4. **Self Join**
   - Used when joining a table to itself.
   - Example: Employee and Manager are in the same Employee table.
   - Query pattern:
     ```sql
     SELECT e.Name, m.Name AS ManagerName
     FROM Employees e
     JOIN Employees m ON e.ManagerId = m.EmployeeId;
     ```

5. **UNION and UNION ALL**
   - `UNION` combines result sets and removes duplicates.
   - `UNION ALL` combines result sets without removing duplicates.
   - Use when appending data from multiple sources or queries.

6. **String Functions**
   - `CONCAT()`, `UPPER()`, `LOWER()`, `LEFT()`, `RIGHT()`, `TRIM()`, `SUBSTRING()`
   - Helpful for formatting and extracting portions of strings.

7. **LIKE and Wildcards**
   - Pattern matching with `%` and `_`.
   - Example: `WHERE Email LIKE '%@gmail.com'`

8. **STRING_AGG() with WITHIN GROUP**
   - Aggregates multiple row values into a single string.
   - Example: `STRING_AGG(Name, ', ') WITHIN GROUP (ORDER BY Name)`

9. **Date Functions**
   - `MONTH()`, `YEAR()` to extract date parts.
   - Useful for filtering or grouping by time periods.

10. **Pattern Matching**
   - Combine `LIKE`, `NOT LIKE`, wildcards for validations.
   - Example: Validate emails or search patterns.

11. **CASE Statements in Aggregations**
   - Conditional logic inside aggregates.
   - Example:
     ```sql
     AVG(CASE WHEN Gender = 'M' THEN 1.0 ELSE 0.0 END)
     ```

12. **Window Functions**
   - `RANK()`, `FIRST_VALUE()`, `ROW_NUMBER()`
   - Applied using `OVER()` clause for analytical purposes.

13. **Multi-Column IN Support**
   - SQL Server does not support `IN ((a,b))`, unlike MySQL.

14. **Built-in Functions on Window Functions**
   - Example: `DATEADD(DAY, -1, MIN(OrderDate) OVER (PARTITION BY CustomerId))`

15. **Group By on Joins**
   - Combine aggregation with joins.
   - Example: Count orders per customer.

16. **UNION vs. UNION ALL Considerations**
   - Use `UNION` to eliminate duplicates.
   - Use `UNION ALL` for performance when duplicates are allowed.

17. **Inline Tables (Derived Tables)**
   - Create temporary table on the fly.
   - Example:
     ```sql
     SELECT category FROM (VALUES ('Low'), ('Average')) AS category(category)
     ```

18. **PIVOT and UNPIVOT**
   - Transform rows to columns (PIVOT) and columns to rows (UNPIVOT).

19. **Window Function Scope**
   - Can only be used in `SELECT` and `ORDER BY` clauses.

20. **UNION with ORDER BY**
   - ORDER BY applies to the final result only.
   - Cannot use ORDER BY in individual SELECTs within UNION.

21. **UNION Syntax**
   - Do not end first query with semicolon.
   - Correct format:
     ```sql
     SELECT col1 FROM table1
     UNION
     SELECT col1 FROM table2;
     ```

22. **Advanced Window Functions**
   - Use `ROWS BETWEEN` for time-based comparisons.
   - `LAG()`, `LEAD()` to access previous/next row values.
   - Example:
     ```sql
     LAG(SalesAmount, 1) OVER (PARTITION BY StoreId ORDER BY SaleDate)
     ```