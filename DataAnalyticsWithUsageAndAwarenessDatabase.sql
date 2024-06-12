Select * from Awareness

Select * from Usage

--data cleaning
--remove <7.0 to 7.0
Update Usage
set [Median age of initiation of Cigarette (in years)]=
case 
    when [Median age of initiation of Cigarette (in years)] is null then 7.0
	else [Median age of initiation of Cigarette (in years)]
end

Update Usage
set [Median age of initiation of Bidi (in years)]=
case 
    when [Median age of initiation of Bidi (in years)] is null then 7.0
	else [Median age of initiation of Bidi (in years)]
end

Update Usage
set [Median age of initiation of smokeless tobacco (in years)]=
case 
    when [Median age of initiation of smokeless tobacco (in years)] is null then 7.0
	else [Median age of initiation of smokeless tobacco (in years)]
end
--delete duplicates
with rownum as(
select *,ROW_NUMBER() over (
                            partition by [State/UT],[Area] order by [State/UT]) row_num
from Usage)

delete from rownum where row_num>1

--delete unused columns
  Alter Table Usage drop column F51,F52,F53,F54,F55,F56,F57,F58,F59


SELECT * FROM Usage
WHERE "State/UT" = 'Tamil Nadu';

--tobacco users
--percentage of tobacco users by each state
Select [State/UT],AVG((([Ever tobacco users (%)]+[Current tobacco users (%)]+[Ever tobacco smokers (%)]+[Current tobacco smokers (%)]+[Ever smokeless tobacco users (%)]+[Current smokeless tobacco users (%)]+[Ever users of  paan masala together with tobacco (%)]+[Ever users of  paan masala together with tobacco (%)])*0.125)) as TotalPercentageOfTobaccoUsersByState
from Usage group by [State/UT] order by TotalPercentageOfTobaccoUsersByState desc

--percentage of tobacco users by each area
Select [State/UT],[Area],(([Ever tobacco users (%)]+[Current tobacco users (%)]+[Ever tobacco smokers (%)]+[Current tobacco smokers (%)]+[Ever smokeless tobacco users (%)]+[Current smokeless tobacco users (%)]+[Ever users of  paan masala together with tobacco (%)]+[Ever users of  paan masala together with tobacco (%)])*0.125) as TotalPercentageOfTobaccoUsersByArea
from Usage order by [State/UT]

--average age of initiation of any drug by each state
Select [State/UT],AVG(([Median age of initiation of Cigarette (in years)]+[Median age of initiation of Bidi (in years)]+[Median age of initiation of smokeless tobacco (in years)])/3) as MedianAgeOfDrugInitiationByState
from Usage group by [State/UT] order by MedianAgeOfDrugInitiationByState

--percentage of bidi users by each state
select [State/UT],AVG(([Current bidi users (%)]+[Ever bidi users (%)])*0.5) as PercentageOfBidiUsersByState
from Usage group by [State/UT] order by PercentageOfBidiUsersByState desc


--view Combines usage statistics with quitting statistics to see both metrics together.
create view usersquitters as
(
SELECT 
    u.[State/UT],
    AVG(
        (
            u.[Ever tobacco users (%)] +
            u.[Current tobacco users (%)] +
            u.[Ever tobacco smokers (%)] +
            u.[Current tobacco smokers (%)] +
            u.[Ever smokeless tobacco users (%)] +
            u.[Current smokeless tobacco users (%)] +
            u.[Ever users of  paan masala together with tobacco (%)]
        ) * 0.142857
    ) AS PercentageOfTobaccoUsersByState,
    AVG(
        (
            a.[Ever tobacco smokers who quit in last 12 months (%)] +
            a.[Current tobacco smokers who tried to quit smoking in the past 12] +
            a.[Current tobacco smokers who wanted to quit smoking now   (%)] +
            a.[Ever  smokeless tobacco users who quit  in last 12 months (%)] +
            a.[Current smokeless tobacco users who tried to quit tobacco in the] +
            a.[Current  smokeless tobacco users who wanted to quit tobacco now]
        ) * 0.166
    ) AS PercentageOfQuittersByState 
FROM 
    Usage u 
INNER JOIN 
    Awareness a
ON 
    u.[State/UT] = a.[State/UT] 
GROUP BY 
    u.[State/UT], 
    a.[State/UT]
)

create view riskstatus as
(
Select 
*,
CASE
    When PercentageOfTobaccoUsersByState>40 or PercentageOfQuittersByState<20 then 'Very High Risk'
	When PercentageOfTobaccoUsersByState>30 or PercentageOfQuittersByState<30 then 'High Risk'
	When PercentageOfTobaccoUsersByState>20 or PercentageOfQuittersByState<40 then 'Risk'
	When PercentageOfTobaccoUsersByState>10 or PercentageOfQuittersByState<50 then 'Less Risk'
	else 'Very Less Risk'
end as RiskStatus
from usersquitters
)
--Combines usage statistics with quitting statistics to see both metrics together.
SELECT 
    u.[State/UT],
    AVG(
        (
            u.[Ever tobacco users (%)] +
            u.[Current tobacco users (%)] +
            u.[Ever tobacco smokers (%)] +
            u.[Current tobacco smokers (%)] +
            u.[Ever smokeless tobacco users (%)] +
            u.[Current smokeless tobacco users (%)] +
            u.[Ever users of  paan masala together with tobacco (%)]
        ) * 0.142857
    ) AS PercentageOfTobaccoUsersByState,
    AVG(
        (
            a.[Ever tobacco smokers who quit in last 12 months (%)] +
            a.[Current tobacco smokers who tried to quit smoking in the past 12] +
            a.[Current tobacco smokers who wanted to quit smoking now   (%)] +
            a.[Ever  smokeless tobacco users who quit  in last 12 months (%)] +
            a.[Current smokeless tobacco users who tried to quit tobacco in the] +
            a.[Current  smokeless tobacco users who wanted to quit tobacco now]
        ) * 0.166
    ) AS PercentageOfQuittersByState 
FROM 
    Usage u 
INNER JOIN 
    Awareness a
ON 
    u.[State/UT] = a.[State/UT] 
GROUP BY 
    u.[State/UT], 
    a.[State/UT]
order by
     PercentageOfTobaccoUsersByState desc,PercentageOfQuittersByState

--temporary table for showing risk status
SELECT 
    u.[State/UT],
    AVG(
        (
            u.[Ever tobacco users (%)] +
            u.[Current tobacco users (%)] +
            u.[Ever tobacco smokers (%)] +
            u.[Current tobacco smokers (%)] +
            u.[Ever smokeless tobacco users (%)] +
            u.[Current smokeless tobacco users (%)] +
            u.[Ever users of  paan masala together with tobacco (%)]
        ) * 0.142857
    ) AS PercentageOfTobaccoUsersByState,
    AVG(
        (
            a.[Ever tobacco smokers who quit in last 12 months (%)] +
            a.[Current tobacco smokers who tried to quit smoking in the past 12] +
            a.[Current tobacco smokers who wanted to quit smoking now   (%)] +
            a.[Ever  smokeless tobacco users who quit  in last 12 months (%)] +
            a.[Current smokeless tobacco users who tried to quit tobacco in the] +
            a.[Current  smokeless tobacco users who wanted to quit tobacco now]
        ) * 0.166
    ) AS PercentageOfQuittersByState 
into #useaware
FROM 
    Usage u 
INNER JOIN 
    Awareness a
ON 
    u.[State/UT] = a.[State/UT] 
GROUP BY 
    u.[State/UT], 
    a.[State/UT]
order by
     PercentageOfTobaccoUsersByState desc,PercentageOfQuittersByState
Select 
[State/UT],
CASE
    When PercentageOfTobaccoUsersByState>40 or PercentageOfQuittersByState<20 then 'Very High Risk'
	When PercentageOfTobaccoUsersByState>30 or PercentageOfQuittersByState<30 then 'High Risk'
	When PercentageOfTobaccoUsersByState>20 or PercentageOfQuittersByState<40 then 'Risk'
	When PercentageOfTobaccoUsersByState>10 or PercentageOfQuittersByState<50 then 'Less Risk'
	else 'Very Less Risk'
end as RiskStatus
from #useaware 

--procedure to display risk status
alter procedure displayRisk @State nvarchar(30)
as
SELECT 
    u.[State/UT],
    AVG(
        (
            u.[Ever tobacco users (%)] +
            u.[Current tobacco users (%)] +
            u.[Ever tobacco smokers (%)] +
            u.[Current tobacco smokers (%)] +
            u.[Ever smokeless tobacco users (%)] +
            u.[Current smokeless tobacco users (%)] +
            u.[Ever users of  paan masala together with tobacco (%)]
        ) * 0.142857
    ) AS PercentageOfTobaccoUsersByState,
    AVG(
        (
            a.[Ever tobacco smokers who quit in last 12 months (%)] +
            a.[Current tobacco smokers who tried to quit smoking in the past 12] +
            a.[Current tobacco smokers who wanted to quit smoking now   (%)] +
            a.[Ever  smokeless tobacco users who quit  in last 12 months (%)] +
            a.[Current smokeless tobacco users who tried to quit tobacco in the] +
            a.[Current  smokeless tobacco users who wanted to quit tobacco now]
        ) * 0.166
    ) AS PercentageOfQuittersByState 
into #useaware
FROM 
    Usage u 
INNER JOIN 
    Awareness a
ON 
    u.[State/UT] = a.[State/UT] 
where u.[State/UT] =@State
GROUP BY 
    u.[State/UT], 
    a.[State/UT]
order by
     PercentageOfTobaccoUsersByState desc,PercentageOfQuittersByState
Select 
[State/UT],
CASE
    When PercentageOfTobaccoUsersByState>40 or PercentageOfQuittersByState<20 then 'Very High Risk'
	When PercentageOfTobaccoUsersByState>30 or PercentageOfQuittersByState<30 then 'High Risk'
	When PercentageOfTobaccoUsersByState>20 or PercentageOfQuittersByState<40 then 'Risk'
	When PercentageOfTobaccoUsersByState>10 or PercentageOfQuittersByState<50 then 'Less Risk'
	else 'Very Less Risk'
end as RiskStatus
from #useaware
go

exec displayRisk @State='Tamil Nadu'

--use procedure to display a particular city quitters and users of drug

alter procedure display @State nvarchar(30)
as
SELECT 
    u.[State/UT],
    AVG(
        (
            u.[Ever tobacco users (%)] +
            u.[Current tobacco users (%)] +
            u.[Ever tobacco smokers (%)] +
            u.[Current tobacco smokers (%)] +
            u.[Ever smokeless tobacco users (%)] +
            u.[Current smokeless tobacco users (%)] +
            u.[Ever users of  paan masala together with tobacco (%)]
        ) * 0.142857
    ) AS PercentageOfTobaccoUsersByState,
    AVG(
        (
            a.[Ever tobacco smokers who quit in last 12 months (%)] +
            a.[Current tobacco smokers who tried to quit smoking in the past 12] +
            a.[Current tobacco smokers who wanted to quit smoking now   (%)] +
            a.[Ever  smokeless tobacco users who quit  in last 12 months (%)] +
            a.[Current smokeless tobacco users who tried to quit tobacco in the] +
            a.[Current  smokeless tobacco users who wanted to quit tobacco now]
        ) * 0.166
    ) AS PercentageOfQuittersByState 
FROM 
    Usage u 
INNER JOIN 
    Awareness a
ON 
    u.[State/UT] = a.[State/UT] 
where u.[State/UT] =@State
GROUP BY 
    u.[State/UT], 
    a.[State/UT]
order by
     PercentageOfTobaccoUsersByState desc,PercentageOfQuittersByState
go

exec display @State='Tamil Nadu'

--common table expressions
with useaware as(
SELECT 
    u.[State/UT],
    AVG(
        (
            u.[Ever tobacco users (%)] +
            u.[Current tobacco users (%)] +
            u.[Ever tobacco smokers (%)] +
            u.[Current tobacco smokers (%)] +
            u.[Ever smokeless tobacco users (%)] +
            u.[Current smokeless tobacco users (%)] +
            u.[Ever users of  paan masala together with tobacco (%)]
        ) * 0.142857
    ) AS PercentageOfTobaccoUsersByState,
    AVG(
        (
            a.[Ever tobacco smokers who quit in last 12 months (%)] +
            a.[Current tobacco smokers who tried to quit smoking in the past 12] +
            a.[Current tobacco smokers who wanted to quit smoking now   (%)] +
            a.[Ever  smokeless tobacco users who quit  in last 12 months (%)] +
            a.[Current smokeless tobacco users who tried to quit tobacco in the] +
            a.[Current  smokeless tobacco users who wanted to quit tobacco now]
        ) * 0.166
    ) AS PercentageOfQuittersByState 
FROM 
    Usage u 
INNER JOIN 
    Awareness a
ON 
    u.[State/UT] = a.[State/UT] 
GROUP BY 
    u.[State/UT], 
    a.[State/UT])
Select 
*,
CASE
    When PercentageOfTobaccoUsersByState>40 or PercentageOfQuittersByState<20 then 'Very High Risk'
	When PercentageOfTobaccoUsersByState>30 or PercentageOfQuittersByState<30 then 'High Risk'
	When PercentageOfTobaccoUsersByState>20 or PercentageOfQuittersByState<40 then 'Risk'
	When PercentageOfTobaccoUsersByState>10 or PercentageOfQuittersByState<50 then 'Less Risk'
	else 'Very Less Risk'
end as RiskStatus
from useaware 

--high exposure place analysis
create view expose as
(
Select [State/UT],AVG([Exposure to tobacco smoke at home/public place (%)]) as 'Home/Public Place',AVG([Exposure to tobacco smoke at home   (%)]) as 'Home',AVG([Exposure to tobacco smoke inside any enclosed public  places  (%]) as 'Enclosed Public Place',AVG([Exposure to tobacco smoke at any outdoor public places  (%)]) as 'Outdoor Public Places',AVG([Students who saw anyone smoking inside the  school building or o]) as 'School'
from Awareness group by [State/UT]
)

select *,
case 
    when [Home/Public Place]>[Home] and [Home/Public Place]>[Enclosed Public Place] and [Home/Public Place]>[Outdoor Public Places] and [Home/Public Place]>[School] then 'Home/Public Place'
	when [Home]>[Home/Public Place] and [Home]>[Enclosed Public Place] and [Home]>[Outdoor Public Places] and [Home]>[School] then 'Home'
	when [Enclosed Public Place]>[Home/Public Place] and [Enclosed Public Place]>[Home] and [Enclosed Public Place]>[Outdoor Public Places] and [Enclosed Public Place]>[School] then 'Enclosed Public Place'
	when [Outdoor Public Places]>[Home/Public Place] and [Outdoor Public Places]>[Home] and [Enclosed Public Place]<[Outdoor Public Places] and [Outdoor Public Places]>[School] then 'Outdoor Public Places'
	else 'School'
end as 'Highest exposure is due to'
from expose


--highest source analysis
create view source as
( 
select [State/UT],AVG(([Major source of tobacco product- Cigarette: Store   (%)]+[Major source of tobacco product- Bidi: Store   (%)])/2) as 'Store',AVG(([Major source of tobacco product- Cigarette: Paan shop (%)]+[Major source of tobacco product- Bidi: Paan shop (%)])/2) as 'Paan Shop'
from Awareness group by [State/UT]
)

create view majorsource as
(
Select *,
case
    when [Store]>[Paan Shop] then 'Store'
	else 'Paan Shop'
end as 'Major Source of Drug'
from source
)
--major reason of avoidance by students 
alter view reason as
(
select [State/UT],AVG(([Refused sale of cigarette because of age in past 30 days   (%)]+[Refused sale of bidi because of age in past 30 days   (%)]+[Refused sale of smokeless tobacco because of age in past 30 days])/3) as 'Refusal sale due to age',
AVG([Students who noticed anti-tobacco messages anywhere in past 30 d]) as 'AntiMessagesAnywhere',AVG([Students who noticed anti-tobacco messages in mass media in past]) as 'AntiMessagesMedia',
AVG([Students who noticed anti-tobacco messages at sporting,  fairs, ]) as 'AntiMessagesSocialGathering', AVG([Students who noticed health warnings on any tobacco product/ciga]) as 'WarningsInPackages'
,AVG([Students who were taught in class about harmful effects of tobac]) as 'ClassTeaching',AVG([Students who thought it is difficult to quit once someone starts]) as 'OthersDifficultyToQuit',
AVG([Students who thought other people’s tobacco smoking is harmful t]) as 'OthersHealthHazards',AVG([Students who favoured ban on smoking inside enclosed public plac]) as 'BanEnclosedPublicPlace',
AVG([Students who favoured ban on smoking at outdoor public places (%]) as 'BanOutdoorPublicPlace'
from Awareness group by [State/UT] 
)

alter view reasonofavoidance as
(
select *,
    GREATEST(
        [Refusal sale due to age],
        [AntiMessagesAnywhere],
        [AntiMessagesMedia],
        [AntiMessagesSocialGathering],
        [WarningsInPackages],
        [ClassTeaching],
        [OthersDifficultyToQuit],
        [OthersHealthHazards],
        [BanEnclosedPublicPlace],
        [BanOutdoorPublicPlace]
        
    ) AS MaxReasonValue,
    CASE
        WHEN [Refusal sale due to age] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'Refusal sale due to age'
        WHEN [AntiMessagesAnywhere] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'AntiMessagesAnywhere'
        WHEN [AntiMessagesMedia] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'AntiMessagesMedia'
        WHEN [AntiMessagesSocialGathering] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'AntiMessagesSocialGathering'
        WHEN [WarningsInPackages] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'WarningsInPackages'
        WHEN [ClassTeaching] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'ClassTeaching'
        WHEN [OthersDifficultyToQuit] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'OthersDifficultyToQuit'
        WHEN [OthersHealthHazards] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'OthersHealthHazards'
        WHEN [BanEnclosedPublicPlace] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'BanEnclosedPublicPlace'
        WHEN [BanOutdoorPublicPlace] = GREATEST([Refusal sale due to age], [AntiMessagesAnywhere], [AntiMessagesMedia], [AntiMessagesSocialGathering], [WarningsInPackages], [ClassTeaching], [OthersDifficultyToQuit], [OthersHealthHazards], [BanEnclosedPublicPlace], [BanOutdoorPublicPlace]) THEN 'BanOutdoorPublicPlace'
    END AS MaxReason
FROM reason
)



