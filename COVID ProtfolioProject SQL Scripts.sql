/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Funtions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Order by 3,4;

-- Select the Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by location, date;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by location, date;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, ROUND(((total_cases/population)*100),2) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'United States'
Order by location, date;

-- Looking at Countries with Hightest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount,  ROUND(MAX((total_cases/population)*100),2) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc;

-- Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc;

-- Showing Continents with the Hightest Death Count per Population
Select location as Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc;


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as 
	total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2;

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as 
	total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;


-- Using CTE to perform Calculation on Partion By in previous query

With PopvsVac (continent, location, date, population, New_Vaccinations,
	RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PopvsVac;


-- Using TEMP TABLE to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null;

Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null;