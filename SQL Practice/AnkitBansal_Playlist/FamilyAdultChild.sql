create table family 
(
person varchar(5),
type varchar(10),
age int
);
delete from family ;
insert into family values ('A1','Adult',54)
,('A2','Adult',53),('A3','Adult',52),('A4','Adult',58),('A5','Adult',54),('C1','Child',20),('C2','Child',19),('C3','Child',22),('C4','Child',15);


/*
insert into family values('C5', 'Child', 18), ('C6', 'Child', 17);
delete from family where family.person in ('C5', 'C6');
*/

select * from family;

/* Each Adult should accompany a child to the park. Child shoudln't be alone, excess parent may visite the park alone */

select f1.person, f1.age, f2.person, f2.age from family f1 left join family f2 on LEFT(f1.person, 1) = 'A' and LEFT(f2.person, 1) = 'C' and SUBSTRING(f1.person, 2, len(f1.person)-1) = SUBSTRING(f2.person, 2, len(f2.person)-1) where f1.person like 'A%';		

/* If Names follow apattern, Need not use Row_Number*/

with cte1 as(select * from family where family.person like 'A%'),
cte2 as (select * from family where family.person like'C%')
select cte1.person, cte1.age, cte2.person, cte2.age from cte1 left join cte2 on SUBSTRING(cte1.person, 2, len(cte1.person)-1) = SUBSTRING(cte2.person, 2, len(cte2.person)-1);



/* Please find below, If we have unique person names without any appended numbers */

with cte1 as(select *, ROW_NUMBER() over(order by person) as 'Arow' from family where type='Adult'),
cte2 as (select *, ROW_NUMBER() over(order by person) as 'Crow' from family where type='Child')
select cte1.person, cte1.age, cte2.person, cte2.age from cte1 left join cte2 on cte1.Arow  = cte2.Crow