SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioCovid..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Displays the probability of death if COVID-19 is contracted in a specific country
SELECT location, date, total_cases, total_deaths, ((total_deaths / total_cases) * 100) AS deathpercentage
FROM PortfolioCovid..CovidDeaths
WHERE location like '%states%'
AND continent is NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
-- Displays the percentage of population infected with COVID-19
SELECT location, date, population, total_cases,  ((total_cases / population) * 100) AS percentpopulationinfected
FROM PortfolioCovid..CovidDeaths
-- WHERE location like '%states%'
ORDER BY 1,2


-- Displays the countries with the Highest Infection Rate compared to the Population
SELECT location, population, MAX(total_cases) AS highestinfectioncount,  MAX((total_cases / population) * 100) AS percentpopulationinfected
FROM PortfolioCovid..CovidDeaths
GROUP BY location, population
ORDER BY percentpopulationinfected DESC


-- Displays the countries with the Highest Death Count per Population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM PortfolioCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY totaldeathcount DESC


-- Displays the continents with the Highest Death Counts
SELECT continent, MAX(CAST(total_deaths AS INT)) AS totaldeathcount
FROM PortfolioCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY totaldeathcount DESC


-- Displays the global Death Percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS deathpercentage
FROM PortfolioCovid..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


-- Displays the global Death Percentage by Date
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS deathpercentage
FROM PortfolioCovid..CovidDeaths
WHERE continent is not NULL
GROUP BY DATE
ORDER BY 1,2


-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingvaccinations
FROM PortfolioCovid..CovidDeaths dea
JOIN PortfolioCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- CTE to display the percentage of the population that received the vaccination
WITH POPvsVAC (continent, location, date, population, new_vaccinations, rollingvaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingvaccinations
FROM PortfolioCovid..CovidDeaths dea
JOIN PortfolioCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (rollingvaccinations/population)*100 AS vacpercentage
FROM POPvsVAC

-- TEMP TABLE to display the percentage of the population that received the vaccination
DROP TABLE IF EXISTS #PercentPopulationVacc
CREATE TABLE #PercentPopulationVacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinations numeric
)

INSERT INTO	#PercentPopulationVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingvaccinations
FROM PortfolioCovid..CovidDeaths dea
JOIN PortfolioCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (rollingvaccinations/population)*100 AS vacpercentage
FROM #PercentPopulationVacc


-- Creating a View to store data for future visualizations
CREATE VIEW PercentPopulationVacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingvaccinations
FROM PortfolioCovid..CovidDeaths dea
JOIN PortfolioCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVacc