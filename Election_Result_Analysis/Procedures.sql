/* SP to retrieve details of candidate count group by Gender, Deposit Eligibility */
Drop procedure IF EXISTS gender_count;
create procedure gender_count (

    @gender nvarchar(10)
    
)
as 
Select Gender, ElectionDepositEligibility, Count(Candidate) as 'Number of Candidates Contested' 
from NationalElection where Gender = @gender
GROUP BY Gender,ElectionDepositEligibility order by Count(Candidate) desc

Exec gender_count @gender='F'

/* SP to retrieve details of candidates who contested in a constituency, state in the specified year */

Drop procedure IF EXISTS get_CandidateDetails;
create procedure get_CandidateDetails(
	@state nvarchar(50),
	@year int,
	@pc_name nvarchar(50)
)
as
Select * from NationalElection where Year=@year and State=@state and PC_Name=@pc_name order by Year,State,PC_Name;

Exec get_CandidateDetails @year='2014',@state='Andhra Pradesh',@pc_name='Bapatla'


/* SP to retrieve details of candidate who won in a constituency, state in the specified year */

drop procedure IF EXISTS get_winner_details;
create procedure get_winner_details(

	@state nvarchar(50),
	@year int,
	@pc_name nvarchar(50)
)
as
with cte_win as(

	select Year, State, PC_Name, Candidate, Party, VotePoll as VotesPolled, 
	(VotePoll-lead(VotePoll) over (partition by Year, PC_Name order by VotePoll desc)) as Margin, 
	rank() over(partition by Year, PC_Name order by VotePoll desc) as r from NationalElection
	where state=@state and year=@year and PC_Name=@pc_name
)
select Year, State, PC_Name, Candidate, Party, VotesPolled, Margin from cte_win where r=1;

Exec get_winner_details @year=2014, @state='Andhra Pradesh', @pc_name='Rajampet'


/* SP to retrieve details of candidates contested from a political party, state in the specified year */

drop procedure IF EXISTS get_Party_Contestants;
create procedure get_Party_Contestants(

	@partyabbr nvarchar(50),
	@year int,
	@state nvarchar(50)
)
as
select Year,State,PC_Name,Candidate, Gender, Party, VotePoll, TotalVotesPolled, VoteShare, Result from NationalElection where Year=@year and PartyAbbr=@partyabbr and State=@state order by Year,State,Candidate,Result desc;

Exec get_Party_Contestants @year=2014, @partyabbr='YSRCP', @State='Andhra Pradesh'


/* SP to retrieve details of contestants who won in atleast specified number of elections between 1977 and 2014 */

drop procedure IF EXISTS get_candidate_win_count;
create procedure get_candidate_win_count(
	
	@wins int
)
as
select Candidate, PC_Name, Count(*) as 'Wins' from NationalElection 
where Result='Won' group by Candidate, PC_Name having Count(*) > @wins order by Wins desc;

Exec get_candidate_win_count @wins=5