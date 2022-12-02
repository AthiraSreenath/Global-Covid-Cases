/*
COVID 19 DATA EXPLORATION

Data Source: 
https://ourworldindata.org/covid

Goal: 
1. Total cases, total deaths, total vaccine doses administered around the globe
2. To identify top 10 countries with highest/lowest number of cases and deaths
3. To identify top 10 countries with highest/lowest number of infection rate and fatality rate
4. To identify top 10 countries with the best/worst vaccination stats
5. Creating view to store consolidated country level info

Skills Used: Converting Datatypes, Aggregate Functions, Window Functions, Joins, Derived Tables, CTEs, Creating Views
*/

--TABLES
select * from CasesDeaths; --COUNT:218475
select * from VaccinationInfo; --COUNT:218475
select * from TestingInfo; --COUNT:218475

--Converting datatypes
select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where table_name='CasesDeaths';

alter table CasesDeaths
alter column population float;

alter table CasesDeaths
alter column total_cases float;

alter table CasesDeaths
alter column total_deaths float;


--GOAL1 : Total cases, total deaths and total vaccine doses administered across the globe
--Tables: CasesDeaths, VaccinationInfo

select sum(total_cases) as total_cases from
(select location, max(total_cases) as total_cases
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') 
and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location) total;

select sum(total_deaths) as total_deaths from
(select location, max(total_deaths) as total_deaths
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') 
and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location) total;

select sum(total_vaccinations) as total_vaccinations_doses from
(select location, max(total_vaccinations) as total_vaccinations
from VaccinationInfo
where location not in ('World','Asia','North America','South America','Africa') 
and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location) total;

select sum(people_fully_vaccinated) as people_fully_vaccinated from
(select location, max(people_fully_vaccinated) as people_fully_vaccinated
from VaccinationInfo
where location not in ('World','Asia','North America','South America','Africa') 
and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location) total;

select sum(people_vaccinated) as people_partially_vaccinated from
(select location, max(people_vaccinated) as people_vaccinated
from VaccinationInfo
where location not in ('World','Asia','North America','South America','Africa') 
and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location) total;

--GOAL2 : To identify the countries with highest number of cases and deaths
--Tables: CasesDeaths

--Required columns and data
select iso_code,continent,location,date,population,total_cases,total_deaths
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%';

--Top 10 countries with highest number of cases
select top 10 location, total_cases
from(
select location, max(total_cases) as total_cases
from CasesDeaths
group by location)temp
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
order by total_cases desc

--Top 10 countries with highest number of deaths
select top 10 location, total_deaths
from(
select location, max(total_deaths) as total_deaths
from CasesDeaths
group by location)temp
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
order by total_deaths desc

--Top 10 countries with highest number of cases as a portion of population
select top 10 location,max_infection_rate
from
(select location,max( cast(round((total_cases/population)*100,2) as float) ) as max_infection_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location
)temp
order by max_infection_rate desc;

--Top 10 countries with covid death as a portion of population
select top 10 location, death_per_population
from(
select location,max( cast(round((total_deaths/population)*100,2) as float) ) as death_per_population
from CasesDeaths
group by location)temp
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
order by death_per_population desc;


--Goal 3: To identify top 10 countries with highest/lowest number of infection rate and fatality rate

--Infection Rate (Number of infected cases wrt total population)
select
location,date, round(infected_rate,2) as infected_rate
from
(select location,date,population,total_cases,(total_cases/population)*100 as infected_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%')temp;

--Highest infection rate in each Country
select location,max(round((total_cases/population)*100,2)) as max_infection_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location
order by max_infection_rate desc

--Country with the highest and lowest infection rate
select top 10 location,high_infection_rate
from
(select location,max(round((total_cases/population)*100,2)) as high_infection_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location
)temp
order by high_infection_rate desc;

select top 10 location,low_infection_rate
from
(select location,max(round((total_cases/population)*100,2)) as low_infection_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location)temp
where low_infection_rate is not null
and low_infection_rate<>0
order by low_infection_rate ;

--Fatality rate  (Number of deaths wrt total cases)
select
location,date, round(fatality_rate,2) as fatality_rate
from
(select location, date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 as fatality_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
)TEMP
where fatality_rate is not null;

--Highest fatality rate in each Country
select location,max( cast(round((total_deaths/total_cases)*100,2) as float) ) as fatality_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location
order by fatality_rate desc;

--Country with the highest and lowest fatality rate
select top 10 location,fatality_rate
from
(select location,max( round((total_deaths/total_cases)*100,2)) as fatality_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location)temp
order by fatality_rate desc;

select top 10 location,fatality_rate
from
(select location,max( cast(round((total_deaths/total_cases)*100,2) as float) ) as fatality_rate
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location)temp
where fatality_rate is not null
order by fatality_rate ;



--GOAL4 : To identify the countries with the best/worst vaccination stats
--Tables: CasesDeaths, VaccinationInfo

--Selecting required columns and data
select iso_code,location, date ,total_vaccinations,people_vaccinated, people_fully_vaccinated,
total_boosters,new_vaccinations
from VaccinationInfo
where location not in ('World','Asia','North America','South America','Africa') and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%';

--Top 10 countries with the highest and number of doses administred (windows function, join)
select top 10 location, max(total_vaccinations) as total_vaccinations FROM
(
select v.iso_code,v.location, v.date, p.population,
max(total_vaccinations ) over (partition by v.location order by v.location, v.date) as total_vaccinations
from VaccinationInfo v
join CasesDeaths p
on v.location=p.location
and v.date=p.date 
where v.location not in ('World','Asia','North America','South America','Africa') 
and (v.location not like '%income%' or v.location not like '% income%')
and v.location not like '%Europe%' )temp
group by location
order by total_vaccinations desc;

select top 10 location, max(total_vaccinations) as total_vaccinations FROM
(
select v.iso_code,v.location, v.date, p.population,
max(total_vaccinations ) over (partition by v.location order by v.location, v.date) as total_vaccinations
from VaccinationInfo v
join CasesDeaths p
on v.location=p.location
and v.date=p.date 
where v.location not in ('World','Asia','North America','South America','Africa') 
and (v.location not like '%income%' or v.location not like '% income%') 
and v.location not like '%Europe%')temp
where total_vaccinations is not null
group by location
order by total_vaccinations;


--Top 10 countries with highest and lowest number of fully vaccinated people wrt total population (using CTE, join)
WITH CTE_FullyVaccinated as
(select v.iso_code,v.location, v.date, p.population,
max( cast(round((v.people_fully_vaccinated/p.population)*100,2) as float) ) over (partition by v.location order by v.location, v.date) as fully_vaccinated_population
from VaccinationInfo v
join CasesDeaths p
on v.location=p.location
and v.date=p.date
where v.location not in ('World','Asia','North America','South America','Africa') 
and (v.location not like '%income%' or v.location not like '% income%') 
and v.location not like '%Europe%')
select top 10 location, max(fully_vaccinated_population) as fully_vaccinated_population  
from CTE_FullyVaccinated
where fully_vaccinated_population is not null
group by location
order by fully_vaccinated_population desc;


WITH CTE_FullyVaccinated as
(select v.iso_code,v.location, v.date, p.population,
max( cast(round((v.people_fully_vaccinated/p.population)*100,2) as float) ) over (partition by v.location order by v.location, v.date) as fully_vaccinated_population
from VaccinationInfo v
join CasesDeaths p
on v.location=p.location
and v.date=p.date
where v.location not in ('World','Asia','North America','South America','Africa') 
and (v.location not like '%income%' or v.location not like '% income%') 
and v.location not like '%Europe%')
select top 10 location, max(fully_vaccinated_population) as fully_vaccinated_population  
from CTE_FullyVaccinated
where fully_vaccinated_population is not null
group by location
order by fully_vaccinated_population;

--Top 10 countries with highest and lowest number of partially vaccinated people wrt total population (using CTE, join)
WITH CTE_PartiallyVaccinated as
(select v.iso_code,v.location, v.date, p.population,
max( cast(round((v.people_vaccinated/p.population)*100,2) as float) ) over (partition by v.location order by v.location, v.date) as partially_vaccinated_population
from VaccinationInfo v
join CasesDeaths p
on v.location=p.location
and v.date=p.date
where v.location not in ('World','Asia','North America','South America','Africa') 
and (v.location not like '%income%' or v.location not like '% income%') 
and v.location not like '%Europe%')
select top 10 location, max(partially_vaccinated_population) as partially_vaccinated_population  
from CTE_PartiallyVaccinated
where partially_vaccinated_population is not null
group by location
order by partially_vaccinated_population desc;


WITH CTE_PartiallyVaccinated as
(select v.iso_code,v.location, v.date, p.population,
max( cast(round((v.people_vaccinated/p.population)*100,2) as float) ) over (partition by v.location order by v.location, v.date) as partially_vaccinated_population
from VaccinationInfo v
join CasesDeaths p
on v.location=p.location
and v.date=p.date
where v.location not in ('World','Asia','North America','South America','Africa') 
and (v.location not like '%income%' or v.location not like '% income%') 
and v.location not like '%Europe%')
select top 10 location, max(partially_vaccinated_population) as partially_vaccinated_population  
from CTE_PartiallyVaccinated
where partially_vaccinated_population is not null
group by location
order by partially_vaccinated_population;



----GOAL5 : Creating view to store consolidated country level info

Create View VW_Country_Level_Summary as
(
select c.location,max(c.total_cases) as total_cases, max(c.total_deaths) as total_deaths,
max( cast(round((c.total_cases/c.population)*100,2) as float) ) as infection_rate, 
max( cast(round((c.total_deaths/c.total_cases)*100,2) as float) ) as fatality_rate, 
max(v.total_vaccinations) as total_vaccinations,
max( cast(round((v.people_vaccinated/v.population)*100,2) as float) ) as partially_vaccinated_population,
max( cast(round((v.people_fully_vaccinated/v.population)*100,2) as float) ) as fully_vaccinated_population
from CasesDeaths c
join VaccinationInfo v
on c.location=v.location
and c.date=v.date
where c.location not in ('World','Asia','North America','South America','Africa') and (c.location not like '%income%' or c.location not like '% income%') 
and c.location not like '%Europe%'
group by c.location
);

select * from VW_Country_Level_Summary;

Create View VW_Country_Graph as
(
select c. date, c.location,c.total_cases as total_cases, c.total_deaths as total_deaths,
cast(round((c.total_cases/c.population)*100,2) as float) as infection_rate, 
cast(round((c.total_deaths/c.total_cases)*100,2) as float) as fatality_rate, 
v.total_vaccinations as total_vaccinations,
cast(round((v.people_vaccinated/v.population)*100,2) as float) as partially_vaccinated_population,
cast(round((v.people_fully_vaccinated/v.population)*100,2) as float) as fully_vaccinated_population
from CasesDeaths c
join VaccinationInfo v
on c.location=v.location
and c.date=v.date
where c.location not in ('World','Asia','North America','South America','Africa') and (c.location not like '%income%' or c.location not like '% income%') 
and c.location not like '%Europe%'
);

select * from VW_Country_Graph;

Create View VW_TotalCount_CasesDeaths as
(
select sum(total_cases) as total_cases,
sum(total_deaths) as total_deaths
 from
(select location, max(total_cases) as total_cases,
max(total_deaths) as total_deaths
from CasesDeaths
where location not in ('World','Asia','North America','South America','Africa') 
and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location) total
);

select * from VW_TotalCount_CasesDeaths;

Create View VW_TotalCount_Vaccinations as
(
select sum(total_vaccinations) as total_vaccinations, 
sum(people_fully_vaccinated) as people_fully_vaccinated, 
sum(people_vaccinated) as people_partially_vaccinated
from
(select location, max(total_vaccinations) as total_vaccinations,
max(people_fully_vaccinated) as people_fully_vaccinated,
max(people_vaccinated) as people_vaccinated
from VaccinationInfo
where location not in ('World','Asia','North America','South America','Africa') 
and (location not like '%income%' or location not like '% income%') 
and location not like '%Europe%'
group by location) total
);

select * from VW_TotalCount_Vaccinations;


select  location, ((total_vaccinations/population)*100) as vaccinated_pop FROM
(
select v.iso_code,v.location, v.date, p.population,
max(total_vaccinations ) over (partition by v.location order by v.location, v.date) as total_vaccinations
from VaccinationInfo v
join CasesDeaths p
on v.location=p.location
and v.date=p.date 
where v.location not in ('World','Asia','North America','South America','Africa') 
and (v.location not like '%income%' or v.location not like '% income%')
and v.location not like '%Europe%' )temp
group by location
order by total_vaccinations desc;
