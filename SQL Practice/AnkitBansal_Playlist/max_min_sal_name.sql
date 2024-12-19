create table deptEmp
(
emp_name varchar(10),
dep_id int,
salary int
);
delete from deptEmp;
insert into deptEmp values 
('Siva',1,30000),('Ravi',2,40000),('Prasad',1,50000),('Sai',2,20000)


delete from deptEmp where emp_name = 'Kevin';

select * from deptEmp;

with cte as(
select dep_id, max(salary) as 'max', min(salary) as 'min' from deptEmp group by dep_id)
select deptEmp.dep_id, 
	max(case when deptEmp.Salary=cte.max then deptEmp.emp_name else null end) as 'emp_max_salary_name',
	max(case when deptEmp.salary=cte.min then deptEmp.emp_name else null end) as 'emp_minsalary_name'
from cte inner join deptEmp on cte.dep_id=deptEmp.dep_id
group by deptEmp.dep_id


select x.dep_id, x.emp_name, y.emp_name from (select dep_id, emp_name, DENSE_RANK() over(partition by dep_id order by salary Desc) as 'maxi' from deptEmp) x
inner join
(select dep_id, emp_name, DENSE_RANK() over(partition by dep_id order by salary asc) as 'mini' from deptEmp) y
on x.dep_id = y.dep_id where x.maxi=1 and y.mini=1;

