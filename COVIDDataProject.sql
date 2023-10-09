
Select * 
From CovidDeaths$
where continent is not null 
Order by 3,4

--Select * 
--From dbo.CovidVaccinations$
--Order by 3,4

Select location,date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
where continent is not null 
Order by 1,2

--Looking at Total cases vs total deaths
--Shows the likelihood of contacting the disease based on your country

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%India%'
and where continent is not null 
Order by 1,2

--total_cases vs population
--Shows what percentage of population got covid

Select location,date, total_cases,population, (total_cases/population)*100 as Percentagepopulationinfected
From CovidDeaths$
where continent is not null 
--Where location like '%India%'
Order by 1,2

--Highest infection rate according to population

Select location,population, max(total_cases) as highest_Count, Max(total_cases/population)*100 as highest_infection_rate
From CovidDeaths$
--Where location like '%India%'
Group by location,population
Order by  highest_infection_rate desc

--Showing highest Death Count

Select location,max(cast(total_deaths as int)) as total_death_count
From CovidDeaths$
--Where location like '%India%'
where continent is not null 
Group by location
Order by  total_death_count desc

--Let's break things down by continent


Select continent, max(cast(total_deaths as int)) as total_death_count
From CovidDeaths$
--Where location like '%India%'
where continent is not null 
Group by continent
Order by  total_death_count desc

--Global Numbers

Select  sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as global_death_percentage
From CovidDeaths$
--Where location like '%India%'
where continent is not null 
Order by 1,2

--Calling Another table

SELECt * 
from CovidVaccinations$

--Join

SELECt * 
from CovidDeaths$ dea 
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs total vaccintions

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--,(Rolling_people_vaccinated/population)*100
from CovidDeaths$ dea 
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location like '%India%'
order by 2,3

--Use CTE

With rollpop_vs_vac (continent,location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--,(Rolling_people_vaccinated/population)*100
from CovidDeaths$ dea 
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location like '%India%'
--order by 2,3
)

Select *, (rolling_people_vaccinated/population)*100 as rollpop_vac_percentage
From rollpop_vs_vac
order by 2,3


--temp table

Drop table if exists #Percentage_people_vaccinated
Create table #Percentage_people_vaccinated
(
Continent nvarchar(225),
location nvarchar(225),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #Percentage_people_vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--,(Rolling_people_vaccinated/population)*100
from CovidDeaths$ dea 
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location like '%India%'
--order by 2,3

Select *, (rolling_people_vaccinated/population)*100 as rollpop_vac_percentage
From #Percentage_people_vaccinated




-- Creating view to store data for later

Create view Percentage_people_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--,(Rolling_people_vaccinated/population)*100
from CovidDeaths$ dea 
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location like '%India%'
--order by 2,3
