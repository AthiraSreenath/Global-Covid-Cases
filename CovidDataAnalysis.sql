--TABLES

select * from CovidInfo
select * from CasesDeaths
select * from CountryInfo
select * from PatientInfo
select * from VaccinationInfo
select * from TestingInfo

--COUNT OF DATA IN EACH TABLES

select count(*) from CovidInfo
select count(*) from CasesDeaths
select count(*) from CountryInfo
select count(*) from PatientInfo
select count(*) from VaccinationInfo
select count(*) from TestingInfo

--TOTAL CASES VS TOTAL DEATHS VS TOTAL POPULATION

select 
population,total_cases,total_deaths,(total_cases/population)*100 as ContractedPercent,(total_deaths/total_cases)*100 as DeathPercent
from CasesDeaths