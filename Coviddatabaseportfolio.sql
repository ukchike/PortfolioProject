
Select *
From databaseportfolio..coviddeath
Where continent is not null
Order by 3,4


--Select *
--From databaseportfolio..covidvaccination
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From databaseportfolio..coviddeath
Order by 1,2

--Looking at toal case vs total death
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From databaseportfolio..coviddeath
Where continent is not null
Where Location = 'Africa'
Order by 1,2

--Total cases vs population
Select Location, date, total_cases, population, (total_cases/population)*100 as Casepercentage
From databaseportfolio..coviddeath
Where continent is not null
Where Location = 'Nigeria'
Order by 1,2

--Country with highest infection rate
Select Location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as poulationinfectedpercentage
From databaseportfolio..coviddeath
Where continent is not null
--Where Location = 'Nigeria'
Group by population, Location
Order by 4 desc

--Country with highest death count per population
Select Location, population, MAX(total_deaths) as deathcount, MAX((total_deaths/population))*100 as deathrate
From databaseportfolio..coviddeath
Where continent is not null
--Where Location = 'Nigeria'
Group by population, Location
Order by 3 desc

--Continent with highest death count per population
Select Location, population, MAX(total_deaths) as deathcount, MAX((total_deaths/population))*100 as deathrate
From databaseportfolio..coviddeath
Where continent is not null
--Where Location = 'Nigeria'
Group by Location, population
Order by 4 desc

--continent with highest death 
Select continent, MAX(cast(total_deaths as int)) as deathcount, MAX((total_deaths/population))*100 as deathrate
From databaseportfolio..coviddeath
Where continent is not null
Group by continent
Order by deathcount  desc

--GLOBAL NUMBERS
Select date, SUM(new_cases)  as total_cases, SUM(cast(new_deaths as int)) as  total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathrate
From databaseportfolio..coviddeath
Where continent is not null
Group by date
Order by 1

--total population
Select *
From databaseportfolio..coviddeath dea
Join databaseportfolio..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--total poulation vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From databaseportfolio..coviddeath dea
Join databaseportfolio..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Where location = 'Nigeria'
order by 1,2,3

--total poulation vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as vaccinatedpeople
--, (vaccinatedpeople/dea.population)*100
From databaseportfolio..coviddeath dea
Join databaseportfolio..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Where location = 'Nigeria'
order by 2,3

--total poulation vs vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as vaccinatedpeople
--, (vaccinatedpeople/dea.population)*100
From databaseportfolio..coviddeath dea
Join databaseportfolio..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Where location = 'Nigeria'
order by 2,3

--use as cte

with popvsvac (continent, location, date, population, new_vacccinations, vaccinatedpeople)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as vaccinatedpeople
--, (vaccinatedpeople/dea.population)*100
From databaseportfolio..coviddeath dea
Join databaseportfolio..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
select *,  (vaccinatedpeople/population)*100
from popvsvac


--TEMP TABLE

drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Vaccinatedpeople numeric,
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as vaccinatedpeople
--, (vaccinatedpeople/dea.population)*100
From databaseportfolio..coviddeath dea
Join databaseportfolio..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
select *,  (vaccinatedpeople/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualisation

Create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as vaccinatedpeople
From databaseportfolio..coviddeath dea
Join databaseportfolio..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
