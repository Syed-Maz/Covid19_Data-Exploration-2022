
Select *
From PortfolioProject1..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by  1,2

-- Total cases VS Total deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where location like '%India%'
order by  1,2

-- Total cases VS Population
-- Shows what percent of people got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From PortfolioProject1..CovidDeaths
where location like '%India%'
order by  1,2

-- Countries with Highest infection Rate compare to Population

Select Location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject1..CovidDeaths
--where location like '%India%'
Group by Location, population
order by  InfectedPopulationPercentage desc

-- Countries with Highest Death Count per population
Select Location, MAX(cast(total_deaths as int))  as TotalDeathCount
From PortfolioProject1..CovidDeaths
--where location like '%India%'
where continent is not null
Group by Location
order by  TotalDeathCount desc

-- Breaking things by Continent
Select continent, MAX(cast(total_deaths as int))  as TotalDeathCount
From PortfolioProject1..CovidDeaths
--where location like '%India%'
where continent is not null
Group by continent
order by  TotalDeathCount desc

-- Global Numbers
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as Totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
group by date
order by 1,2

--total Number
Select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as Totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total population VS Vaccinations (Joining two tables)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as DailyVaccinationUpdate
From PortfolioProject1..CovidDeaths Dea
Join PortfolioProject1..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE
with PopulationVSVaccination (Continent, location, Date, population, new_vaccinations, DailyVaccinationUpdate)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as DailyVaccinationUpdate
From PortfolioProject1..CovidDeaths Dea
Join PortfolioProject1..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select *,(DailyVaccinationUpdate/population)*100
From PopulationVSVaccination

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	DailyVaccinationUpdate numeric
	)

Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as DailyVaccinationUpdate
From PortfolioProject1..CovidDeaths Dea
Join PortfolioProject1..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *,(DailyVaccinationUpdate/population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated

-- Create view for visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as DailyVaccinationUpdate
From PortfolioProject1..CovidDeaths Dea
Join PortfolioProject1..CovidVaccinations Vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select * From PercentPopulationVaccinated