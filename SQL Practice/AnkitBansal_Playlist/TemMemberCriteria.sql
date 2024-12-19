create table Ameriprise_LLC
(
teamID varchar(2),
memberID varchar(10),
Criteria1 varchar(1),
Criteria2 varchar(1)
);
insert into Ameriprise_LLC values 
('T1','T1_mbr1','Y','Y'),
('T1','T1_mbr2','Y','Y'),
('T1','T1_mbr3','Y','Y'),
('T1','T1_mbr4','Y','Y'),
('T1','T1_mbr5','Y','N'),
('T2','T2_mbr1','Y','Y'),
('T2','T2_mbr2','Y','N'),
('T2','T2_mbr3','N','Y'),
('T2','T2_mbr4','N','N'),
('T2','T2_mbr5','N','N'),
('T3','T3_mbr1','Y','Y'),
('T3','T3_mbr2','Y','Y'),
('T3','T3_mbr3','N','Y'),
('T3','T3_mbr4','N','Y'),
('T3','T3_mbr5','Y','N');


select * from Ameriprise_LLC;

/* Type 1: Create a column, get the count(), filter the resultset and then create a final result column */


with cte as
(select *, case when Criteria1 = 'Y' and Criteria2 = 'Y' then 'Y'
					else 'N'
				end as 'Custom'
				from Ameriprise_LLC), cte2 as
(select cte.*, count(cte.Custom) over (partition by cte.teamID, cte.Custom) as 'ctr' from cte)
select cte2.teamID, cte2.memberID, cte2.Criteria1, cte2.Criteria2, cte2.Custom, 
		case when cte2.Custom ='Y' and cte2.ctr >=2 then 'Y' else 'N'
		end as 'Result' from cte2 order by cte2.memberID;

/* Type 2: Identify the Count of Team Members and Join - Create a new column */

with cte as(
select *, case when Criteria1 = 'Y' and Criteria2 = 'Y' then 'Y'
					else 'N'
				end as 'Custom'
				from Ameriprise_LLC), cte2 as(
select cte.teamID, cte.Custom, count(cte.Custom) as 'ctr' from cte  where cte.Custom='Y' group by cte.teamID, cte.Custom having count(cte.Custom) >= 2)
select *, case when a.Criteria1 = 'Y' and a.Criteria2='Y' and cte2.ctr>=2 then 'Y' else 'N' end as result from cte a left join cte2 on a.teamID=cte2.teamID and a.Custom = cte2.Custom;
