CREATE TABLE [emp_salary]
(
    [emp_id] INTEGER  NOT NULL,
    [name] NVARCHAR(20)  NOT NULL,
    [salary] NVARCHAR(30),
    [dept_id] INTEGER
);


INSERT INTO emp_salary
(emp_id, name, salary, dept_id)
VALUES(101, 'sohan', '3000', '11'),
(102, 'rohan', '4000', '12'),
(103, 'mohan', '5000', '13'),
(104, 'cat', '3000', '11'),
(105, 'suresh', '4000', '12'),
(109, 'mahesh', '7000', '12'),
(108, 'kamal', '8000', '11');

insert into emp_salary values(111, 'zzzz', '3000', '11');

select * from emp_salary;

with cte as(
select emp_id, dept_id, salary, rank() over(partition by dept_id order by salary) r from emp_salary), 
cte2 as(
select cte.*, count(cte.r) over(partition by cte.dept_id, cte.salary) as 'Same Salary' from emp_salary es inner join cte on cte.emp_id = es.emp_id)
select cte2.emp_id, cte2.dept_id, cte2.salary from cte2 where cte2.[Same Salary] > 1;

select emp_id, dept_id, salary, count(*) over(partition by dept_id, salary) as 'Same Salary' from emp_salary;