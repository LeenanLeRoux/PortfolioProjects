
--Select data we are going to be using
SELECT location, date , total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[Covid Deaths]
ORDER BY 1,2


-- Looking at total cases vs total deaths (death percentage)
SELECT location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
WHERE location LIKE 'south africa'
ORDER BY 1,2


--Looking at total cases vs population
--shows what percentage of population got covid
SELECT location, date , population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..[Covid Deaths]
WHERE location LIKE 'south africa'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..[Covid Deaths]
--WHERE location LIKE 'south africa'
GROUP BY location ,population
ORDER BY PercentagePopulationInfected desc


--Showing countries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not NULL
GROUP BY location 
ORDER BY TotalDeathCount desc

--LET's BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS
SELECT date , SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
Group by date
ORDER BY 1,2


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[CovidVaccines] vac
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[CovidVaccines] vac
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select * , (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100
from PopvsVac


-- TEMP TABLE
DROP TABLE if exists #percentPopulationVaccinted
CREATE TABLE #percentPopulationVaccinted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #percentPopulationVaccinted
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[CovidVaccines] vac
    on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

Select * , (cast(RollingPeopleVaccinated as float)/cast(Population as float))*100
from #percentPopulationVaccinted

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------



--Creating view to store data for later visualizations
CREATE VIEW percentPopulationVaccinted as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[CovidVaccines] vac
    on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


SELECT * 
FROM percentPopulationVaccinted