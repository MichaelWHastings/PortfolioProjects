SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

-- Select the data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Altering data types for easier organization

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE PortfolioProject..dbo.CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN date DATE

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN population float

-- COMPARING DATA BY COUNTRY

-- Comparing Total Cases to Total Deaths

-- Shows percentage of COVID cases that end in death by country over time

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Comparing Total Cases to Population

-- Shows number of cases as a percentage of the population of a given country

SELECT location, date, total_cases, population, (total_cases/population)*100 AS case_percentage
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Comparing Countries by their highest Infection Rate

SELECT location, population, MAX(total_cases) as highest_infection_count, (MAX(total_cases)/population)*100 as highest_case_percentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 4 desc

-- Comparing Countries by Death Counts

SELECT location, MAX(total_deaths) as Total_Death_Count, MAX(cast(total_deaths_per_million as float))
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent is not null
GROUP BY location 
ORDER BY 3 desc

-- COMPARING DATA BY CONTINENT

-- Comparing Continents by death count

SELECT continent, MAX(total_deaths) as Total_Death_Count
FROM PortfolioProject.dbo.CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY 2 desc

-- GLOBAL DATA

-- Viewing global total cases, deaths, and percentage of cases that lead to death

SELECT date, SUM(total_cases) as global_cases, SUM(total_deaths) as global_deaths, SUM(total_deaths/total_cases) as global_death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1

-- Comparing Vaccination to Total Population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2, 3

-- Using a CTE

-- Viewing rolling percentage of vaccinations over time

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
AS
( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (rolling_total_vaccinations/Population)*100 as rolling_vacc_percentage
FROM PopvsVac

-- Using a Temp Table

DROP TABLE if exists #PopulationvsVacc 
CREATE TABLE #PopulationvsVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
new_vaccinations numeric,
rolling_total_vaccinations numeric
)

Insert into #PopulationvsVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (rolling_total_vaccinations/Population)*100 as rolling_vacc_percentage
FROM #PopulationvsVacc

-- Creating a view for Vizualisation

CREATE VIEW vPopulationvsVacc as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM PortfolioProject.dbo.CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location 
	AND dea.date = vac.date 
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT * 
FROM vPopulationvsVacc