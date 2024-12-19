create table input (
id int,
formula varchar(10),
value int
)
insert into input values (1,'1+4',10),(2,'2+1',5),(3,'3-2',40),(4,'4-1',20);



select * from [input];


with cte as(
select id, formula, LEFT(formula, 1) as 'op1', RIGHT(formula, 1) as 'op2', [value] from input)
select cte.id, cte.formula, cte.[value], case when cte.formula like '%+%' 
					then (select value from input where id = cte.op1) + (select value from input where id = cte.op2)
					when cte.formula like '%-%'
					then (select value from input where id = cte.op1) - (select value from input where id = cte.op2)
				end as 'Calculation'
				from cte;

				/* LIKE is used to check if the operator is available in the formula  */
				/* This can be performed using LEFT(formula, 1), RIGHT(formula, 1), SUBSTRING(formula, 2, 1) */
				/* Also, cte can be used to join with the actual table to get corresponding operand values */