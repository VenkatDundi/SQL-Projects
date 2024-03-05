
## National Election Result Analysis

This project focuses on analyzing National Election Result data using a SQL Server database. The objective is to identify interesting insights within the dataset, highlighting trends in election results across the country based on various parameters such as year, state, constituency, and respective political party. 

This analysis aims to provide valuable statistics and trends from election results, aiding the public in understanding correlations between political power and community growth and development. By examining the performance of political parties and candidates over time and across different regions, this analysis simplifies the electoral outcomes.


### Source Data:

The Source data contains National Election Result records - (Lok Sabha) India from 1977 to 2014 across all the constituencies and states in the Country. This is a comma separated values file with around 76000 records, which has been made available as a part of this repository.


### Data Cleaning and Initial Formatting:

Below tasks have been included:

```
Data Capture, Loading, and Exploration
Handling NULL values in the dataset
Alter table - Update columns based on requirement
Create new fields with respective calculations
```

### Use of this Analysis:

I have explored the dataset and extracted some questions out of it, for which meaningful outcomes can be derived by executing SQL queries on the data set. This involves usage of various concepts in SQL like, 

>DML Operations, 
>Working with NULL values, 
>Common Table Expressions (CTEs), 
>Window Functions, 
>Creation of new fields,
>Update the table with calculated field values, 
>Conditionals (IIF, CASE),
>Joins
>Capturing Inconsistent Data,
>Operators - IN, NOT IN, INTERSECT, EXCEPT, and so on,


Please find some questions to extract details from data:

1. What are the total number of records with no Candidate Name? -   Updated Incosistent Data having no Candidate Name
2. What is the distribution of election participants based on Gender? -     Group by used on Gender
3. What are the total Votes Polled for each constituency? -     Created a new column and updated with calculated values
4. What is the VoteShare of each Candidate? -   Created a new column and populated it using (VotesPolled/TotalVotesPolled)
5. What is the Election Deposit Eligibility of each Candidate? -    Created a new column with values: "YES" if VotePolled > (1/6)th of Total Votes Polled, Else "NO"
6. What is the distribution of election participants based on Deposit Eligibility?
7. Who are the Candidates won in each Consituency? -    Used Rank() to identify Winners
8. What is the Winning margin for each candidate who won the election? -    Used Joins, Rank() to identify margin
9. What are the constituencies where there is only one Candidate as per the data set? -     Used lag() & lead()
10. What is the status of each candidate who contested in election? -   Created a new field to store the result status of election
11. Who are the Candidates won in multiple terms? -     Group by number of wins for each candidate
12. Who are candidates those did not loose atleast once among their contested places? -    Used NOT IN to exclude the filter
13. What are the constituencies where each candidates contested in multiple places in a term? -     Used Count(Constituencies) & Group by functions
14. What is the winning seat distribution of Political Party? -     Group by Year, Party()
15. What is the Win Percentage for each political party which atleast won a single seat? -  Used (Wins/Total Contested) calculation for each Political party
16. What are the details of party which contested but didn't win atleast a single seat in the country? -    Count if won seats IS NULL
17. What are the favourite constituencies for each Political party distributed by Party, Constituency? -     Group by Party, Constituency for won seats
18. what are the Political Parties with majority of winning seats in elections distributed by Year, State, Constituency? -   Rank() the Win count for each party



Steps:

### Create DB:

```
CREATE DATABASE Election;
```

### Import the dataset from Flat file - CSV

```
Right Click on Database --- Tasks --- Import Data --- Flat file --- Browse CSV file

Validate the Data types of fields extracted from file and adjust if required.

Preview sample data
```

### Queries:

1. Initial Exploration of data set

```
select top 10 * from NationalElection;

select count(*) from NationalElection where Candidate!='None Of The Above';
```

2. Data Cleaning and Formatting

> Update the PC Type value when there is no condidate and majority vote share is for NOTA.

```
/* Data Cleaning */

-- Update the Null PC Type when votes polled for the Constituency are not for NOTA - NOT TO ANYONE

update NationalElection set PC_Type=
CASE WHEN PC_Type IS NULL and Candidate<>'None Of The Above' and Party<>'NOTA' THEN 'Unknown'
	 else PC_Type
	 end;

-- Validate the update on table by checking few rows
select top 10 * from NationalElection where PC_Type='Unknown';     
```

> Update the Gender when Votes Polled for NOTA in a constituency

```
NOTA - NONE OF THE ABOVE

update NationalElection set Gender='NA' where Candidate='None Of The Above' and Party='NOTA';

-- Validate the update on table by checking few rows
select top 10 * from NationalElection where Gender='NA';
```

> Creation of New Field - Total Votes Polled: Sum of Votes Polled in each constituency by adding the VotePoll of all Contestants in respective constituency

```

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
```

> Creation of New Field - VoteShare: Calculated for each participant as (VotePoll / TotalVotesPolled), rounded to 3 decimal places

```
alter table NationalElection add VoteShare float(3);

Update NationalElection set VoteShare=
CASE WHEN TotalVotesPolled=0 THEN (CAST(0 as float))
	ELSE round((VotePoll*100)/(CAST(TotalVotesPolled as float)), 3)
	END;
```

> Creation of New Field - ElectionDepositEligibility - "YES" if VoteShare > (1/6)th of Total Votes Polled, Else "NO"

```
alter table NationalElection add ElectionDepositEligibility nvarchar(10);

update NationalElection set ElectionDepositEligibility = IIF(VotePoll>= (TotalVotesPolled/(CAST (6 as float))), 'Yes', 'No')
```


3. Contestants distribution by Gender, Deposit Eligibility

Contestants were grouped based on Gender and Deposit Eligibility and displayed their count.


```
Select Gender, ElectionDepositEligibility, Count(Candidate) as 'Number of Candidates'
from NationalElection
GROUP BY Gender,ElectionDepositEligibility order by Count(Candidate) desc;
```

4. Candidates won in each constituency

The data has been partitioned based on Year & PC_Name and applied rank() considering Votes Polled for each participant in each constituency, and year. Filtered the result with rank=1 to display candidates who has largest Voteshare in respective constituency. 

```
with cte_won as (

	select Year, PC_Name, Candidate, VotePoll, rank() over(partition by Year, PC_Name order by VotePoll desc) as 'rank' from NationalElection
)
select Year, PC_Name, Candidate, VotePoll from cte_won where rank=1 order by Year, PC_Name;
```

5. Winning Margin for Winning Candidates

The difference between the winning candidate and the one following him in the second position is calculated by using lead(), and rank() based on VotePoll.

```
with cte_margin as (
	
	select Year, PC_Name, Candidate, IIF(VotePoll!=0, VotePoll - lead(VotePoll)	over(partition by Year, PC_Name order by VotePoll desc), 0) as 'Margin',
	rank() over (partition by Year, PC_Name order by VotePoll desc) as 'r' from NationalElection
)
select Year, PC_Name, Candidate, Margin from cte_margin where r=1 order by Year, PC_Name;
```

6. Candidates with only 1 contestant

Details of constituency which doesn't have any other candidate as per records - Only 1 contenstant to be assumed

```
with cte_single as (
	
	select Year, PC_Name, Candidate, VotePoll, lag(VotePoll) over(partition by Year, PC_Name order by VotePoll desc) as 'lag_vote', 
	lead(VotePoll) over(partition by Year, PC_Name order by VotePoll desc) as 'lead_vote' from NationalElection

)
SELECT * from cte_single where lag_vote IS NULL and lead_vote IS NULL order by Year, PC_Name;
select * from NationalElection where VotePoll=0;
```

7. Creation of new field - Result

It is calculated based on the the existing values of other fields in the table. When the candidate rank=1, update the result field value as 'Won'. Else, consider it as 'Lost'.

```
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
```

8. Candidates who won in multiple terms

Count of Wins has been calculated for each candidate (Group by Candidate) to understand the number of Wins for each Candidate in Elections.

```
select Candidate, Count(*) as 'Wins' from NationalElection
where Result='Won' group by Candidate order by Wins desc;

select Candidate, Count(*) as 'Wins' from NationalElection
where Result='Won' group by Candidate having Count(*) > 5 order by Wins desc;
```

9. Candidates who didn't loose atleast one term in constituencies where they have contested.

We have considered the candidates who lost and filtered the table with details of those who didn't loose atleast once using "not in" operator.

```
select * from NationalElection where Candidate not in 
(Select Candidate from NationalElection where Result='Lost') order by Result;
```

10. Constituencies where candidates contested multiple times in the same year

Count of Constituencies is considered by grouping the data by Year, Canidate and Party

```
select Year, Candidate, PartyAbbr, Count(PC_Name) as 'Places Contested' from NationalElection 
group by Year, Candidate, PartyAbbr having Count(PC_Name) > 1 order by  Candidate, PartyAbbr, Year;
```

11. Distribution by Party

Caniddates who won from various Political parties are displayed.

```
select Year, Party, Count(Result) as 'Candidates Won' from NationalElection
where Result='Won'
group by Year, Party,Result
order by 'Candidates Won' desc;
```

12. Winning Percentage by Party

Win Percentage is calculated by using (Count(won)/count(contested)) for each party. 2 CTEs are used for calculating counts of each Won, Contested.

```
with cte_total_contest as (

	select Party, Count(Candidate) as contested from NationalElection group by Party
), cte_total_won as (

	select Party, Count(Candidate) as won from NationalElection where Result='Won' group by Party
)
select cte_total_contest.Party, contested, won, round(won/CAST(contested as float), 3) as 'Win Percentage'
from cte_total_contest LEFT JOIN cte_total_won
on cte_total_contest.Party=cte_total_won.Party
order by won desc;
```

13. Favourite Constituencies by Party

Number of wins recorded by each party in a Constituency is extracted by grouping the data by Party and constituency.

```
select Party, PC_Name, Count(PC_Name) as Wins
from NationalElection
where Result='Won'
group by Party, PC_Name
order by Wins desc;
```

14. Maximum number of seats won by political party in each year, and state

First CTE retrieves number of wins recorded by each party whereas second CTE assigns the rank to party based on the number of wins in each state and year.

```
with cte_state_count as (

	select Year, State, Party, Count(Result) as 'Wins' from NationalElection where Result='Won' group by Year, State, Party, Result
), cte_state_won as (

	select Year, State, Party, Wins, rank() over(partition by Year, State order by Wins desc) r from cte_state_count
)
select Year, State, Party, Wins from cte_state_won where r=1;
```
