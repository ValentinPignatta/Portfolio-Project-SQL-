SELECT*
FROM [Portfolio Project]..['Covid deaths']
Where continent is not null 
order by 3,4


--SELECT*
--FROM [Portfolio Project]..['Covid Vaccinations$']
--order by 3,4

Select Location, date, total_cases,new_cases, total_deaths, population
FROM [Portfolio Project]..['Covid deaths']
Where continent is not null 
order by 1,2

-- Total cases vs Total Deaths 

Select Location, date, total_cases, total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM [Portfolio Project]..['Covid deaths']
Where location like '%Argentina%'
--Where continent is not null 
order by 1,2


-- Total Cases vs Population 
Select Location, date, total_cases, Population ,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentageOfPopulationInfected
FROM [Portfolio Project]..['Covid deaths']
Where location like '%Argentina%'
and Where continent is not null 
order by 1,2


-- Countries with Highest Infection Rates Compared to Population

Select Location,  Population , MAX(total_cases) as HighestInfectionCount, MAX((total_cases /population))*100 as PercentageOfPopulationInfected
FROM [Portfolio Project]..['Covid deaths']
--Where location like '%Argentina%'
Where continent is not null 
GROUP BY Location, population
order by PercentageOfPopulationInfected desc

--Countries with Highest Death Count per Population 

Select Location, MAX( cast (total_deaths as int)) as TotalDeathsCount
FROM [Portfolio Project]..['Covid deaths']
Where continent is not null 
GROUP BY Location
order by TotalDeathsCount desc


-- Continents with Highest Death Count per Population (Using the having parameter )
Select Location, MAX( cast (total_deaths as int)) as TotalDeathsCount
FROM [Portfolio Project]..['Covid deaths']
Where continent is  null 
GROUP BY Location
Having location not in ('High income', 'Upper middle income','Lower middle income', 'Low income', 'World')
order by TotalDeathsCount desc


--Continents with Highest Death Count per Population

Select continent, MAX( cast (total_deaths as int)) as TotalDeathsCount
FROM [Portfolio Project]..['Covid deaths']
Where continent is not null 
GROUP BY continent
order by TotalDeathsCount desc


--Global Numbers 
Select date, SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / NULLIF(SUM(new_cases), 0) * 100 as DeathPercentage
From [Portfolio Project]..['Covid deaths']
where continent is not null 
Group by date 
order by 1,2 


Select  SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / NULLIF(SUM(new_cases), 0) * 100 as DeathPercentage
From [Portfolio Project]..['Covid deaths']
where continent is not null 
order by 1,2 

--Total Population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollinPeopleVaccinated
, (RollinPeopleVaccinated/population) * 100
From [Portfolio Project]..['Covid deaths'] dea
Join  [Portfolio Project]..['Covid Vaccinations$'] vac
	on dea.location = vac.location
	AND dea.date = vac.date 
	Where dea.continent is not null 
	order by 2,3





With PopvsVac (continent, location, date, population, new_vaccinations, RollinPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollinPeopleVaccinated
--, (RollinPeopleVaccinated/population) * 100
From [Portfolio Project]..['Covid deaths'] dea
Join  [Portfolio Project]..['Covid Vaccinations$'] vac
	on dea.location = vac.location
	AND dea.date = vac.date 
	Where dea.continent is not null 
	--order by 2,3
	)
Select * , (RollinPeopleVaccinated/population) * 100 as RollinPeopleVaccinatedPercentage 
from PopvsVac



-- Temp Table
DROP TABLE IF exists #PercentagePupulationVaccinated
Create Table #PercentagePupulationVaccinated 
(
Continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePupulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollinPeopleVaccinated/population) * 100
From [Portfolio Project]..['Covid deaths'] dea
Join  [Portfolio Project]..['Covid Vaccinations$'] vac
	on dea.location = vac.location
	AND dea.date = vac.date 
	--Where dea.continent is not null 
	--order by 2,3

	Select * , (RollingPeopleVaccinated /population) * 100 as RollinPeopleVaccinatedPercentage 
from #PercentagePupulationVaccinated



--Creating View to store data for later visualization 
Create View PercentPupulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollinPeopleVaccinated/population) * 100
From [Portfolio Project]..['Covid deaths'] dea
Join  [Portfolio Project]..['Covid Vaccinations$'] vac
	on dea.location = vac.location
	AND dea.date = vac.date 
Where dea.continent is not null 
--order by 2,3


select *
from PercentPupulationVaccinated