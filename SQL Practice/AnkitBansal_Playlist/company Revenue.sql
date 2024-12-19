create table company_revenue 
(
company varchar(100),
year int,
revenue int
)

insert into company_revenue values 
('ABC1',2000,100),('ABC1',2001,110),('ABC1',2002,120),('ABC2',2000,100),('ABC2',2001,90),('ABC2',2002,120)
,('ABC3',2000,500),('ABC3',2001,400),('ABC3',2002,600),('ABC3',2003,800);


select * from company_revenue;  /*Find a company having profits in consecutive years*/

/*lag(revenue) over (partition by company order by [year]) as 'previous year revenue',*/

with cte as(
select company, [year], revenue, lag(revenue) over (partition by company order by [year]) as 'previous revenue' from company_revenue), 
cte2 as(
select *, cte.revenue - cte.[previous revenue] as 'Net Returns', case when  cte.revenue - cte.[previous revenue] > 0 then 'Y' else 'N' end as 'Profit Made', ROW_NUMBER() over(partition by company order by company) as 'rc' from cte)
select cte2.company, count(cte2.company) as 'p', max(cte2.rc) as 'row count' from cte2 where cte2.[Profit Made]='Y' group by cte2.company having count(cte2.company) = max(cte2.rc)-1



/* For lag() ---> we can use as lag(revenue, 1, 0); "0" specifies that the NULL from previous revenue can be made as 0  */