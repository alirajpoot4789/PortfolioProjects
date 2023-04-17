--SELECT * 
--FROM Portfolio_Project_1..CovidVaccinations
--ORDER BY 3,4

SELECT *
FROM Portfolio_Project_1..CovidDeaths
ORDER BY 3,4

--Imported the data through Access, so it added the PK automatically.
ALTER TABLE CovidVaccinations
DROP COLUMN ID;

SELECT location, date, total_tests, new_cases, total_deaths, population 
FROM Portfolio_Project_1..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project_1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Population_cases
FROM Portfolio_Project_1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectedCount,  max((total_cases/population))*100 AS Population_cases
FROM Portfolio_Project_1..CovidDeaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY 4 DESC

-- Showing countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project_1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project_1..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers based on every single date
SELECT date, SUM(new_cases) Total_Cases, SUM(CAST(new_deaths AS INT)) Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percent
FROM Portfolio_Project_1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Numbers Overall
SELECT SUM(new_cases) Total_Cases, SUM(CAST(new_deaths AS INT)) Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Death_Percent
FROM Portfolio_Project_1..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- CTE for checking the population that got vaccinated based on date and location
WITH PopVsVac (continent, location, date, population, new_vaccinations, SumPeopleVac)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as SumPeopleVac 
--(SumPeopleVac/dea.population)*100
FROM Portfolio_Project_1..CovidDeaths dea
JOIN Portfolio_Project_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (SumPeopleVac/population)*100
FROM PopVsVac

-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric, 
SumPeopleVac numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as SumPeopleVac 
--(SumPeopleVac/dea.population)*100
FROM Portfolio_Project_1..CovidDeaths dea
JOIN Portfolio_Project_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (SumPeopleVac/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store Data for visualizations

Create view PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as SumPeopleVac 
--(SumPeopleVac/dea.population)*100
FROM Portfolio_Project_1..CovidDeaths dea
JOIN Portfolio_Project_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
