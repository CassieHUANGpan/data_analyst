/*
Covid data exploration

skills used: Joins, CTE's, Temp Table, Windows Functions, Aggregate Functions, Converting Data Types

*/


-- select data that we need: specific country data
select * from covid_death
where continent is not null
order by location,date;

-- select data that we start with: total cases, new cases, total deaths count by date
select location,date,total_cases,new_cases,total_deaths,population 
from covid_death
where continent is not null
order by 1,2

-- Total cases vs. Total deaths
-- Shows the likelihood of dying if you get covid in a certain country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercent
from covid_death
where location like '%China%'
and continent is not null
order by 1,2



--Countries with the highest infection rate compared to population
select location,population,max(total_cases) as highestInfect_cn,max(total_cases/population)*100 as infectedPercent
from covid_death
where continent is not null
group by location,population
order by 4 desc


--Countries with highest death count per Population
select location,population,max(total_deaths) as death_cn,max(total_deaths/population)*100 as deathPerPopulation
from covid_death
where continent is not null
group by location,population
order by 4 desc


--Breaking things down by continent

--showing continents with the highest death count per population(with income category)
select location,population,max(total_deaths) as death_cn,max(total_deaths/population)*100 as deathPerPopulation
from covid_death
where continent is null
group by location,population
order by 4 desc

--Continents with the highest infection rate compared to population(with income category)
select location,population,max(total_cases) as highestInfect_cn,max(total_cases/population)*100 as infectedPercent
from covid_death
where continent is null
group by location,population
order by 4 desc


--Global numbers(add 'date' if needed to see the trend by date)
select sum(new_cases) as sum_case,sum(cast(new_deaths as int)) as sum_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercent
from covid_death
where continent is not null
--group by date
--order by date



--Total Population vs. Total Vaccinations
--Shows % of population that has recieved at least 1 covid vaccine
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from covid_death d
join covid_vaccination v
    on d.location=v.location
	and d.date=v.date
where d.continent is not null
order by 2,3


--using CTE to perform calculation on Partition by in previous query
With cte as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from covid_death d
join covid_vaccination v
    on d.location=v.location
	and d.date=v.date
where d.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as rollingVaccineRate
from cte
order by location,date


--using Temp table to perform calculation on Partition by in previous query

drop table if exists #vaccinatedPercent
create table #vaccinatedPercent
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #vaccinatedPercent
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from covid_death d
join covid_vaccination v
    on d.location=v.location
	and d.date=v.date
where d.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as rollingVaccineRate
from #vaccinatedPercent
order by location,date


--creating view to store data for later visualization

create view RollingPeopleVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from covid_death d
join covid_vaccination v
    on d.location=v.location
	and d.date=v.date
where d.continent is not null
--order by d.location, d.date

select * from RollingPeopleVaccinated


--Shows the death rate by infection, vaccination rate, and hospital bed per 1000
Create view Correlation_hospitalBed as
select d.location, d.population, v.hospital_beds_per_thousand,
max(total_deaths)/d.population*100 as death_rate
,max(people_fully_vaccinated)/d.population*100 as vaccine_rate
from covid_death d
join covid_vaccination v
    on d.location=v.location
	and d.date=v.date
where d.continent is not null
group by d.location,d.population,v.hospital_beds_per_thousand
--order by death_rate desc
