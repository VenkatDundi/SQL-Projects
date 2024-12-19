create table tickets
(
ticket_id varchar(10),
create_date date,
resolved_date date
);
delete from tickets;
insert into tickets values
(1,'2022-08-01','2022-08-03')
,(2,'2022-08-01','2022-08-12')
,(3,'2022-08-01','2022-08-16');
create table holidays
(
holiday_date date
,reason varchar(100)
);
delete from holidays;
insert into holidays values
('2022-08-11','Rakhi'),('2022-08-15','Independence day');


select * from tickets;

select * from holidays;







with cte as(
select *, datediff(day, create_date, resolved_date) as 'diff', 
		  datepart(weekday, create_date) as 'start_day', 
		  (((datediff(day, create_date, resolved_date)+datepart(weekday, create_date))/7))*2 as 'calc', 
		  case when holiday_date between create_date and resolved_date then 1 else 0 end as 'h' 
		  from tickets, holidays)
select distinct cte.ticket_id, cte.create_date, cte.resolved_date, 
		sum(cte.h) over (partition by cte.create_date, cte.resolved_date) as 'No_of_holidays', 
		cte.diff as 'Actual_days', 
		cte.diff - (cte.calc + sum(cte.h) over (partition by cte.create_date, cte.resolved_date)) 
		as 'Business Days' from cte;
	




	select datepart(weekday, '2024-11-06')


delete from tickets where ticket_id=4;