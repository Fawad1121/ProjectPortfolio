select *
from projectportfolio..coviddeaths
where continent is not null
order by 3,4

--select *
--from projectportfolio..['covid vaccination$']
--order by 3,4

--select Data that we going to be using

select location, date, total_cases, new_cases, total_deaths, population
from projectportfolio..coviddeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you come in contact with covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from projectportfolio..coviddeaths
where location like '%india%'
order by 1,2

--looking at total cases verses population
select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
from projectportfolio..coviddeaths
--where location like '%india%'
order by 1,2


--looking at countries with highest infection rate compared to Population
select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as InfectionPencentage
from projectportfolio..coviddeaths
group by location, population
order by InfectionPencentage desc

--LET'S BREAK THINKGS DOWN BY CONTINENT



--showing Countries with highest Death Count Population
select continent, MAX(cast(total_deaths as int)) as total_deaths_count
from projectportfolio..coviddeaths
where continent is not null
group by continent 
order by total_deaths_count desc

--Global Numbers
select  date, SUM(new_cases) as TotalNewCases,SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathRatePercent
from projectportfolio..coviddeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as TotalNewCases,SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathRatePercent
from projectportfolio..coviddeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2



-- Looking at total Population VS Vaccinations
with PopvsVac (continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
as
(

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast((vac.new_vaccinations)as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated
from projectportfolio..coviddeaths dea
join projectportfolio..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(rollingpeoplevaccinated/population)*100
from PopvsVac
order by 2,3

--use CTE

--with PopvsVac (continent, location, date, population,rollingpeoplevaccinated)
--as

--temp table


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,sum(cast((vac.new_vaccinations)as float)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated
from projectportfolio..coviddeaths dea
join projectportfolio..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * ,(rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated
