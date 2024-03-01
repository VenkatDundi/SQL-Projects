

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

