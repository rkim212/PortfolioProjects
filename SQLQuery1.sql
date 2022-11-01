Select *
	From PortfolioProject..['covid deaths]
	Where continent is not null
	order by 3,4

--Select *
--	From PortfolioProject..['covid vaccinations$']
--	order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..['covid deaths]
	order by 1,2

	-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..['covid deaths]
	Where location like '%states%'
	order by 1,2

	-- Looking at Total Cases vs Population
	-- Shows what percentage of pupulation got Covid

Select Location, date, total_cases, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
	From PortfolioProject..['covid deaths]
	Where location like '%states%'
	order by 1,2

	-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioProject..['covid deaths]
	--Where location like '%states%'
	Group by Location, population
	order by PercentPopulationInfected desc

	-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..['covid deaths]
	--Where location like '%states%'
	Where continent is not null
	Group by Location
	order by TotalDeathCount desc

	-- LET'S BREAK THINGS DOWN BY CONTINTENT

	-- Showing continents with the highest death count per population

	Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..['covid deaths]
	--Where location like '%states%'
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc

	--GLOBAL NUMBERS

	Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
	From PortfolioProject..['covid deaths]
	--Where location like '%states%'
	Where continent is not null
	--Group By date
	order by 1,2

	--Looking at Total Population vs. Vaccinations

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..['covid deaths] dea
	Join PortfolioProject..['covid vaccinations$'] vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	order by 2,3

	--USE CTE

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..['covid deaths] dea
	Join PortfolioProject..['covid vaccinations$'] vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3
	)

	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac

	-- TEMP TABLE

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
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..['covid deaths] dea
	Join PortfolioProject..['covid vaccinations$'] vac
		On dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	Select*, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated


	-- Creating View to store data for later visualization

	Create View PercentPopulationVaccinated as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..['covid deaths] dea
	Join PortfolioProject..['covid vaccinations$'] vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select *
	From PercentPopulationVaccinated