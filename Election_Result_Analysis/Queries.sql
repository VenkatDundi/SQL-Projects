

select count(*) from NationalElection;

select top 10 * from NationalElection;

select count(*) from NationalElection where Candidate!='None Of The Above';


/* Data Cleaning */

-- Update the Null PC Type when votes polled for the Constituency are not for NOTA - NOT TO ANYONE

update NationalElection set PC_Type=
CASE WHEN PC_Type IS NULL and Candidate<>'None Of The Above' and Party<>'NOTA' THEN 'Unknown'
	 else PC_Type
	 end;

-- Validate the update on table by checking few rows
select top 10 * from NationalElection where PC_Type='Unknown';




-- Update the Gender of Candidate when votes polled for the Constituency are for NOTA - NOT TO ANYONE

update NationalElection set Gender='NA' where Candidate='None Of The Above' and Party='NOTA';

-- Validate the update on table by checking few rows
select top 10 * from NationalElection where Gender='NA';



/* Creation of New Field - Total Votes Polled */

alter table NationalElection add TotalVotesPolled real;

with cte_totalvotes as(

	select Year, PC_Name, State, sum(VotePoll) over(partition by Year, PC_Name order by State) as 'Total' from NationalElection
)
Update NationalElection set NationalElection.TotalVotesPolled=cte_totalvotes.Total 
from NationalElection INNER JOIN cte_totalvotes 
on NationalElection.Year=cte_totalvotes.Year 
and NationalElection.PC_Name=cte_totalvotes.PC_Name 
and NationalElection.State=cte_totalvotes.State;

select top 150 * from NationalElection;		-- Validate the update




/* Creation of New Field - VoteShare */

alter table NationalElection add VoteShare float(3);

Update NationalElection set VoteShare=
CASE WHEN TotalVotesPolled=0 THEN (CAST(0 as float))
	ELSE round((VotePoll*100)/(CAST(TotalVotesPolled as float)), 3)
	END;

select top 50 * from NationalElection;



/* Creation of New Field - ElectionDepositEligibility - "YES" if VoteShare > (1/6)th of Total Votes Polled, Else "NO" */

alter table NationalElection add ElectionDepositEligibility nvarchar(10);

update NationalElection set ElectionDepositEligibility = IIF(VotePoll>= (TotalVotesPolled/(CAST (6 as float))), 'Yes', 'No')

select top 50 * from NationalElection;



-- 1. Distribution by Gender, Deposit Eligibility

Select Gender, ElectionDepositEligibility, Count(Candidate) as 'Number of Candidates' 
from NationalElection
GROUP BY Gender,ElectionDepositEligibility order by Count(Candidate) desc;


-- 2. Candidates Won in each constituency

with cte_won as (
	
	select Year, PC_Name, Candidate, VotePoll, rank() over(partition by Year, PC_Name order by VotePoll desc) as 'rank' from NationalElection
)
select Year, PC_Name, Candidate, VotePoll from cte_won where rank=1 order by Year, PC_Name;


-- 3. Winning margin for Candidates won in each constituency

with cte_won as (
	
	select Year, PC_Name, Candidate, VotePoll, rank() over(partition by Year, PC_Name order by VotePoll desc) as 'rank' from NationalElection
), cte_first as (
	
	select Year, PC_Name, Candidate, VotePoll as 'C1' from cte_won where rank=1
), cte_second as (
	
	select Year, PC_Name, Candidate, VotePoll as 'C2' from cte_won where rank=2			-- select Year, PC_Name, Candidate, VotePoll from cte_second order by Year, PC_Name;
)
select cte_first.Year, cte_first.PC_Name, cte_first.Candidate, (C1-C2) as 'Winning Margin' 
from cte_first INNER JOIN cte_second on cte_first.YEAR=cte_second.Year and cte_first.PC_Name = cte_second.PC_Name order by cte_first.Year,cte_first.PC_Name ;




with cte_margin as (
	
	select Year, PC_Name, Candidate, IIF(VotePoll!=0, VotePoll - lead(VotePoll)	over(partition by Year, PC_Name order by VotePoll desc), 0) as 'Margin',
	rank() over (partition by Year, PC_Name order by VotePoll desc) as 'r' from NationalElection
)
select Year, PC_Name, Candidate, Margin from cte_margin where r=1 order by Year, PC_Name;



-- 4. Consituencies with only 1 contestant  --- May be incorrect data as per stats

with cte_single as (
	
	select Year, PC_Name, Candidate, VotePoll, lag(VotePoll) over(partition by Year, PC_Name order by VotePoll desc) as 'lag_vote', 
	lead(VotePoll) over(partition by Year, PC_Name order by VotePoll desc) as 'lead_vote' from NationalElection

)
SELECT * from cte_single where lag_vote IS NULL and lead_vote IS NULL order by Year, PC_Name;
select * from NationalElection where VotePoll=0;




/* Creation of new field - Result : Candidate Won/Lost status update based on Year, Constituency*/ 

alter table NationalElection add Result nvarchar(10);

with cte_ranking as (
	
	select Year, PC_Name, Candidate, VotePoll, rank() over(partition by Year, PC_Name order by VotePoll desc) r from NationalElection
)
Update NationalElection set Result= 'Won' from NationalElection Inner Join cte_ranking 
		on NationalElection.Year=cte_ranking.Year and 
			NationalElection.PC_Name=cte_ranking.PC_Name and 
			NationalElection.Candidate=cte_ranking.Candidate and 
			NationalElection.VotePoll=cte_ranking.VotePoll where r=1;
Update NationalElection set NationalElection.Result='Lost' where Result IS NULL;
select top 50 * from NationalElection;




-- 5. Winning Candidates in multiple terms

select Candidate, Count(*) as 'Wins' from NationalElection 
where Result='Won' group by Candidate order by Wins desc;

select Candidate, Count(*) as 'Wins' from NationalElection 
where Result='Won' group by Candidate having Count(*) > 5 order by Wins desc;


-- 6. Candidates who did not loose atleast once among all contested places


select * from NationalElection where Candidate not in 
(Select Candidate from NationalElection where Result='Lost') order by Result;


-- 7. Constituencies where candidates contested multiple times in the same term


select Year, Candidate, PartyAbbr, Count(PC_Name) as 'Places Contested' from NationalElection 
group by Year, Candidate, PartyAbbr having Count(PC_Name) > 1 order by  Candidate, PartyAbbr, Year;



-- 8. Distribution by Party


select Year, Party, Count(Result) as 'Candidates Won' from NationalElection
where Result='Won'
group by Year, Party,Result 
order by 'Candidates Won' desc;


-- 9. Win Percentage distribution by Party

with cte_total_contest as (
	
	select Party, Count(Candidate) as contested from NationalElection group by Party
), cte_total_won as (

	select Party, Count(Candidate) as won from NationalElection where Result='Won' group by Party
)
select cte_total_contest.Party, contested, won, round(won/CAST(contested as float), 3) as 'Win Percentage' 
from cte_total_contest LEFT JOIN cte_total_won 
on cte_total_contest.Party=cte_total_won.Party
order by won desc;


-- Contested but didn't win alteast a seat

with cte_total_contest as (
	
	select Party, Count(Candidate) as contested from NationalElection group by Party
), cte_total_won as (

	select Party, Count(Candidate) as won from NationalElection where Result='Won' group by Party
)
select cte_total_contest.Party, contested, won, round(won/CAST(contested as float), 3) as 'Win Percentage' 
from cte_total_contest LEFT JOIN cte_total_won 
on cte_total_contest.Party=cte_total_won.Party
where won IS NULL
order by won desc;


-- 10. Favourite Constituencies by Party


select Party, PC_Name, Count(PC_Name) as Wins 
from NationalElection 
where Result='Won' 
group by Party, PC_Name 
order by Wins desc;



-- Seats won by Party distributed by Year, State

with cte_state_count as (
	
	select Year, State, Party, Count(Result) as 'Wins' from NationalElection where Result='Won' group by Year, State, Party, Result
), cte_state_won as (
	
	select Year, State, Party, Wins, rank() over(partition by Year, State order by Wins desc) r from cte_state_count
)
select Year, State, Party, Wins from cte_state_won where r=1;
