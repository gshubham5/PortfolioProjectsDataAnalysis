SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country.
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%India%'
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got COVID
Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP by Location, Population
order by PercentPopulationInfected desc

-- Showing the Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is NOT NULL
GROUP by Location
order by TotalDeathCount desc


--LET's BREAK THINGS BY CONTINENT

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is NOT NULL
GROUP by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is NOT NULL
--GROUP BY date
order by 1,2



--2nd table - CovidVaccinations

-- Looking at TotalPopulation vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is NOT NULL
Order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as  
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is NOT NULL
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is NOT NULL
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is NOT NULL
--Order by 2,3

SELECT *
FROM PercentPopulationVaccinated
