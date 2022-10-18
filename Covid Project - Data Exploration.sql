/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From DevelopmentDatabase..CovidDeaths
where continent is not null
order by 3,4

Select *
From DevelopmentDatabase..CovidVaccinations
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From DevelopmentDatabase..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DevelopmentDatabase..CovidDeaths
Where location like '%states'
order by 1,2


--Looking at Total Cases vs Total Population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From DevelopmentDatabase..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infectino Rate compared to Population
Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From DevelopmentDatabase..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From DevelopmentDatabase..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--BREAKING DOWN BY CONTINENT 

--Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From DevelopmentDatabase..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From DevelopmentDatabase..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From DevelopmentDatabase..CovidDeaths dea
Join DevelopmentDatabase..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE to perform calculation on Partition By in previous query 

With PopvsVac (Continent, Location, Date, Population, New_Vacinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From DevelopmentDatabase..CovidDeaths dea
Join DevelopmentDatabase..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
--Using Temp Table to perform calculation on Partition By in previous query 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From DevelopmentDatabase..CovidDeaths dea
Join DevelopmentDatabase..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From DevelopmentDatabase..CovidDeaths dea
Join DevelopmentDatabase..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null




