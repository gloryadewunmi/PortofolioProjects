/*
Topic: COVID 19 DATA EXPLORATION
SKILLS USED: Joins, CTEs(Common Data Expression), Temp Tables, Windows Functions,Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From CovidDeaths
Where continent is not null
Order By 3,4

Select *
From CovidVaccinations
Order By 3,4

--Selecting Data that we are going to start with....

Select location, date,total_cases, new_cases, total_deaths, population
From CovidDeaths
where continent is not null
Order By 1,2


--Total Cases vs Total Deaths
--This Shows likelihood of percentage of those who die if you contract covid in your country

Select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where total_cases != 0 And location like '%Benin%'
Order By 1,2

--Total Cases vs Population
--Shows what percentage of population infected by covid

Select location, date, population,total_cases,(total_cases/population)*100 as PopulationInfectedPercent
From CovidDeaths
--where location like '%Cameroon%'
where continent is not null
Order By 1,2

--OR
Select location, date, population,total_cases,(total_cases/population)*100 as PopulationInfectedPercent
From CovidDeaths
--Where total_cases != 0 And location like '%Cameroon%'
where  continent is not null And total_cases !=0
Order By 1,2

--Countries with highest infection Rate compared to Population

Select location,population,Max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as PopulationinfectedPercent
From CovidDeaths
--where location like '%Cameroon%'
where continent is not null
Group By location, population
Order By PopulationinfectedPercent desc


--Location(Countries with highest Death Counts per Country Population)

Select location,Max(total_deaths) as TotalDeathCount
From CovidDeaths
--where location like '%Cameroon%'
where continent is not null
Group By location
Order By TotalDeathCount desc

    --OR
Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%Cameroon%'
where continent is not null
Group By location
Order By TotalDeathCount desc

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%Cameroon%'
where continent is null
Group By location
Order By TotalDeathCount desc

--Breaking things down by continents
--Showing continents with the highest death count per population

Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%Cameroon%'
where continent is not null
Group By continent 
Order By TotalDeathCount desc


--GLOBAL NUMBERS


Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/Sum(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is null And new_cases !=0
Group By date
Order By 1,2
  --OR
Select date, Sum(new_cases)as TotalCases, Sum(new_deaths) as TotalDeaths, Sum(new_deaths/new_cases)*100 as DeathPercentage
From CovidDeaths
Where new_cases != 0 And continent is null --And location like '%Benin%'
Group By date
Order By 1,2
   --OR
Select Sum(new_cases)as TotalCases, Sum(new_deaths) as TotalDeaths, Sum(new_deaths/new_cases)*100 as DeathPercentage
From CovidDeaths
Where new_cases != 0 And continent is not null --And location like '%Benin%'
--Group By date
Order By 1,2


--Looking at Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine


Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(Cast(Vac.new_vaccinations as Int)) Over (Partition By Dea.location)
From CovidVaccinations Vac
Join CovidDeaths Dea
On Vac.location = Dea.location
And Vac.date = Dea.date
Where Dea.continent is not null 
Order By 2,3

--OR

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(Convert(int,Vac.new_vaccinations)) Over (Partition By Dea.location Order By Dea.location, Dea.date)
As RollingPeopleVaccinated
From CovidVaccinations Vac
Join CovidDeaths Dea
On Vac.location = Dea.location
And Vac.date = Dea.date
Where Dea.continent is not null
Order By 2,3


--USE CTE (Common Table Expression)
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(Convert(int,Vac.new_vaccinations)) Over (Partition By Dea.location Order By Dea.location, Dea.date)
As RollingPeopleVaccinated
From CovidVaccinations Vac
Join CovidDeaths Dea
On Vac.location = Dea.location
And Vac.date = Dea.date
Where Dea.continent is not null 
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PopulationVaccinated
From PopvsVac


--Using Temp Table to perform Calculation on Partition By in/from previous query

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentagePopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(Convert(int,Vac.new_vaccinations)) Over (Partition By Dea.location Order By Dea.location, Dea.date)
As RollingPeopleVaccinated
From CovidDeaths Dea
Join CovidVaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date
--Where Dea.continent is not null 
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentagePopulationVaccinated


--Creating View to Store data for later Visualization

Create View PercentagePopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
Sum(Convert(int,Vac.new_vaccinations)) Over (Partition By Dea.location Order By Dea.location, Dea.date)
As RollingPeopleVaccinated
From CovidDeaths Dea
Join CovidVaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date
Where Dea.continent is not null 
--Order By 2,3

Select *
From PercentagePopulationVaccinated