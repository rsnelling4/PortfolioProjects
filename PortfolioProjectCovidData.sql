

Select *
From PortfolioProject..COVIDDeaths$
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..COVIDDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths in United States
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percent
From PortfolioProject.dbo.COVIDDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population of United States
Select location, date, total_cases, population, (total_cases/population)*100 as Contracted_Percent
From PortfolioProject.dbo.COVIDDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection rate compared to population
Select Location, Population, MAX(total_cases) as Infected_Count, MAX((total_cases/Population))*100 as Percent_Infected
From PortfolioProject.dbo.COVIDDeaths$
--Where location like '%states%'
group by Location, Population
order by Percent_Infected desc


-- Looking at countries with highest Deaths per Population
Select Location, MAX(cast(total_deaths as int)) as Death_Count
From PortfolioProject.dbo.COVIDDeaths$
--Where location like '%states%'
where continent is not null
group by Location
order by Death_Count desc


-- Looking at continents with highest Deaths
Select continent, MAX(cast(total_deaths as int)) as Deaths_Continent
From PortfolioProject.dbo.COVIDDeaths$
--Where location like '%states%'
where continent is not null
group by continent
order by Deaths_Continent desc

-- Looking at Global data by date
Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Global_Percent
From PortfolioProject.dbo.COVIDDeaths$
where continent is not null
group by date
order by 1,2

-- Looking at Global data combined
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Global_Percent
From PortfolioProject.dbo.COVIDDeaths$
where continent is not null
--group by date
order by 1,2

-- Looking at Total Pop vs Vaccinations
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(cast(vacs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_Vaccinated
from PortfolioProject.dbo.COVIDDeaths$ deaths
join PortfolioProject.dbo.COVIDVaccinations$ vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
order by 2,3


With PopulationVsVacs (continent, location, date, population, new_vaccinations, Rolling_Vaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(cast(vacs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_Vaccinated
from PortfolioProject.dbo.COVIDDeaths$ deaths
join PortfolioProject.dbo.COVIDVaccinations$ vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
-- order by 2,3
)
Select *, (Rolling_Vaccinated/population)*100 as rolling_percent
From PopulationVsVacs


--Create a temp table
Drop Table if exists #PercentageVaccinated
Create Table #PercentageVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinated numeric
)

Insert Into #PercentageVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(cast(vacs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_Vaccinated
from PortfolioProject.dbo.COVIDDeaths$ deaths
join PortfolioProject.dbo.COVIDVaccinations$ vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null
-- order by 2,3

Select *, (Rolling_Vaccinated/population)*100 as rolling_percent
From #PercentageVaccinated



-- Creating Views for visualizations

Create View PercentageOfVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
, SUM(cast(vacs.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_Vaccinated
from PortfolioProject.dbo.COVIDDeaths$ deaths
join PortfolioProject.dbo.COVIDVaccinations$ vacs
	on deaths.location = vacs.location
	and deaths.date = vacs.date
where deaths.continent is not null


Select *
from PercentageOfVaccinated

Create View HighestDeathsByContinent as
Select continent, MAX(cast(total_deaths as int)) as Deaths_Continent
From PortfolioProject.dbo.COVIDDeaths$
--Where location like '%states%'
where continent is not null
group by continent
--order by Deaths_Continent desc

Select *
from HighestDeathsByContinent
Order by Deaths_Continent desc


Create View CasesVsDeathsUSA as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percent
From PortfolioProject.dbo.COVIDDeaths$
Where location like '%states%'
--order by 1,2

Select *
from CasesVsDeathsUSA
order by 1,2
