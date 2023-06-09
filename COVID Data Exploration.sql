SELECT *
FROM [Portfolio Project 1]..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project 1]..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project 1]..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases Vs. Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs. Population

SELECT Location, Date, Population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2

-- What country has the highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM [Portfolio Project 1]..CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC

-- What country had the highest death count per Population

SELECT Location, MAX(cast(total_deaths as INT)) AS HighestDeaths, MAX((total_deaths/population))*100 AS DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY 2 DESC

-- What continent had the highest death count per Population

SELECT location, MAX(cast(total_deaths as INT)) AS HighestDeaths, MAX((total_deaths/population))*100 AS DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE Continent is null
GROUP BY location
ORDER BY 2 DESC



-- Global Numbers

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Population Vs. Vaccinations

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vac)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Vac
FROM [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.Continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_vac/Population)*100 AS Percent_Vac
FROM PopvsVac


--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vac numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Vac
FROM [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.Continent is not null
ORDER BY 2,3

SELECT *, (Rolling_vac/Population)*100 AS Percent_Vac
FROM #PercentPopulationVaccinated


--Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Vac
FROM [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.Continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated