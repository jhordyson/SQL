--Use data from owid-covid-data

select * 
from CovidDeaths
order by 3, 4

select * 
from CovidVaccinations
order by 3, 4

--Select Data that we are going to using

select location, date ,total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2

--Looking at total cases vs total deaths in Peru

select location, date ,total_cases, total_deaths, round(((total_deaths/total_cases)*100),2) death_percentage
from coviddeaths
where location like 'Peru'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

select location, date ,total_cases, population, round(((total_cases/population)*100),2) infected_percentage
from coviddeaths
order by 1,2

--Looking at countries with highest infection rate compare to population

select location, population ,max(total_cases) highest_cases, max(round(((total_cases/population)*100),2)) infected_percentage
from coviddeaths
where continent is not null
group by location, population
order by 4 desc

--Showing countries with highest death count

select location,max(cast(total_deaths as int)) totaldeaths
from coviddeaths
where continent is not null and total_deaths is not null
group by location
order by 2 desc

--Showing continents with highest death count

select continent, SUM(totaldeaths) total_deaths
from (
	select continent,location, MAX(total_deaths) as totaldeaths
	from CovidDeaths
	where continent is not null
	group by continent, location
	) t1
group by continent
order by 2 desc

--Global numbers

select date, sum(new_cases) new_cases, sum(new_deaths) deaths, sum(new_deaths)/sum(new_cases) * 100 death_percentage
from CovidDeaths
where continent is not null and new_cases >= 1 and new_deaths >=1 
group by date
order by 1

--Looking at total population vs vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) 
	as total_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

--Using CTE

with PopvsVac (continent, location, date, population,new_vaccinations, total_vaccinations)
as (
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) 
		as total_vaccinations
	from CovidDeaths cd
	join CovidVaccinations cv
		on cd.location = cv.location
		and cd.date = cv.date
	where cd.continent is not null
	--order by 2,3
)
select * , (total_vaccinations/population)*100 vaccinations_percentage
from PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) 
	as total_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
select * , (total_vaccinations/population)*100 vaccinations_percentage
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) 
	as total_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select * 
from PercentPopulationVaccinated
