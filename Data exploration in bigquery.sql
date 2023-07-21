/*
Covid 19 Data Exploration using BigQuery
Skills used: Joins, CTE's, Temporary Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From `endless-orb-381518.portfolio_project.covid_deaths`
Where continent is not null 
order by 3,4


-- Selecting Data that is going to be worked on first

Select Location, date, total_cases, new_cases, total_deaths, population
From `endless-orb-381518.portfolio_project.covid_deaths`
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From `endless-orb-381518.portfolio_project.covid_deaths`
Where location = "India"
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows the percentage of population that is infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as percentage_infected
From `endless-orb-381518.portfolio_project.covid_deaths`
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Total_cases,  Max((total_cases/population))*100 as percent_population_infected
From `endless-orb-381518.portfolio_project.covid_deaths`
Where Continent is not null
Group by Location, Population
order by percent_population_infected desc


-- Countries with Highest Death Rate compared to Population

Select Location, Population, MAX(total_deaths) as Total_deaths,  Max((total_deaths/population))*100 as percent_population_dead
From `endless-orb-381518.portfolio_project.covid_deaths`
Where Continent is not null
Group by Location, Population
order by percent_population_dead desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(total_deaths) as total_deaths
From `endless-orb-381518.portfolio_project.covid_deaths`
Where continent is not null 
Group by continent
order by total_deaths desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(New_Cases))*100 as death_percentage
From `endless-orb-381518.portfolio_project.covid_deaths`
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations by using "JOIN" and "OVER"
-- Shows Percentage of Population that has taken at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Date) as people_vaccinated
From `endless-orb-381518.portfolio_project.covid_deaths` AS dea
Join `endless-orb-381518.portfolio_project.covid_vaccinations` AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using Common Table Expressions to perform Calculation on previous query

With PopvsVac AS 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Date) as people_vaccinated
From `endless-orb-381518.portfolio_project.covid_deaths` AS dea
Join `endless-orb-381518.portfolio_project.covid_vaccinations` AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (people_vaccinated/Population)*100 AS vaccination_percentage
From PopvsVac

-- Using Temporary Table to perform Calculation on previous query

DROP TABLE IF EXISTS `endless-orb-381518.portfolio_project.percent_vaccinated`

CREATE TABLE `endless-orb-381518.portfolio_project.percent_vaccinated` (
Continent string,
Location string,
Date datetime,
Population int,
New_vaccinations int,
people_vaccinated int
)


Insert into `endless-orb-381518.portfolio_project.percent_vaccinated`
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Date) as people_vaccinated
From `endless-orb-381518.portfolio_project.covid_deaths` dea
Join `endless-orb-381518.portfolio_project.covid_vaccinations` vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Creating View to store data 

Create View percent_vaccinated AS
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Date) as people_vaccinated
From `endless-orb-381518.portfolio_project.covid_deaths` AS dea
Join `endless-orb-381518.portfolio_project.covid_vaccinations` AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)


