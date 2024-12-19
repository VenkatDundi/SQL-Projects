create table people
(id int primary key not null,
 name varchar(20),
 gender char(2));

create table relations
(
    c_id int,
    p_id int,
    FOREIGN KEY (c_id) REFERENCES people(id),
    foreign key (p_id) references people(id)
);

insert into people (id, name, gender)
values
    (107,'Days','F'),
    (145,'Hawbaker','M'),
    (155,'Hansel','F'),
    (202,'Blackston','M'),
    (227,'Criss','F'),
    (278,'Keffer','M'),
    (305,'Canty','M'),
    (329,'Mozingo','M'),
    (425,'Nolf','M'),
    (534,'Waugh','M'),
    (586,'Tong','M'),
    (618,'Dimartino','M'),
    (747,'Beane','M'),
    (878,'Chatmon','F'),
    (904,'Hansard','F');

insert into relations(c_id, p_id)
values
    (145, 202),
    (145, 107),
    (278,305),
    (278,155),
    (329, 425),
    (329,227),
    (534,586),
    (534,878),
    (618,747),
    (618,904);



/* Find Parents for Each Children - Nested Sub Queries*/

select * from people;
select * from relations;

with cte as(
select * from (select c_id, p_id, min(p_id) over (partition by c_id order by p_id) as 'p1', max(p_id) over (partition by c_id order by p_id) as 'p2' , row_number() over (partition by c_id order by p_id desc) as 'rno' from relations) x where p1!=p2)
select 
case when cte.c_id in (select id from people) 
	then (select people.name from people where id = cte.c_id) 
	else '' end as 'Child Name',
case when cte.p1 in (select id from people where people.gender='M') 
		then (select people.name from people where id = cte.p1)
	when cte.p2 in (select id from people where people.gender='M') 
		then (select people.name from people where id = cte.p2)
	else '' end as 'Father''s Name',
case when cte.p2 in (select id from people where people.gender='F') 
		then (select people.name from people where id = cte.p2)
	when cte.p1 in (select id from people where people.gender='F')
		then (select people.Name from people where id = cte.p1)
	else '' end as 'Mother''s Name'
		from cte order by 1;


/*We can use Joins to perform similar operations*/

with cte as(
select r.c_id, p.name, p.gender from relations r inner join people p on r.p_id = p.id)
select cte.c_id, 
		max(case when cte.gender='M' then cte.name end) as 'Fathers''s Name', 
		max(case when cte.gender='F' then cte.name end) as 'Mother''s Name' from cte group by cte.c_id;