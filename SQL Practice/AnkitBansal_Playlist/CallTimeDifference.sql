create table call_start_logs
(
phone_number varchar(10),
start_time datetime
);
insert into call_start_logs values
('PN1','2022-01-01 10:20:00'),('PN1','2022-01-01 16:25:00'),('PN2','2022-01-01 12:30:00')
,('PN3','2022-01-02 10:00:00'),('PN3','2022-01-02 12:30:00'),('PN3','2022-01-03 09:20:00')
create table call_end_logs
(
phone_number varchar(10),
end_time datetime
);
insert into call_end_logs values
('PN1','2022-01-01 10:45:00'),('PN1','2022-01-01 17:05:00'),('PN2','2022-01-01 12:55:00')
,('PN3','2022-01-02 10:20:00'),('PN3','2022-01-02 12:50:00'),('PN3','2022-01-03 09:40:00')
;


select * from call_start_logs;
select * from call_end_logs;

/* Time difference in minutes between the corresponding start time and end time call logs */

with cte1 as(
select *, ROW_NUMBER() over(partition by phone_number order by phone_number, start_time) as 'srn' from call_start_logs),
cte2 as(
select *, ROW_NUMBER() over(partition by phone_number order by phone_number, end_time) as 'ern' from call_end_logs)
select cte1.phone_number, cte1.start_time, cte2.end_time, DATEDIFF(MINUTE, cte1.start_time, cte2.end_time) as 'time difference (mins)' from cte1 inner join cte2 on 
concat(cte1.phone_number, cte1.srn) = concat(cte2.phone_number, cte2.ern);


