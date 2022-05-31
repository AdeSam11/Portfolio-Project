select * from CovidDeathsss;
select * from CovidVaccinationns;

--checking the total cases, total deaths and population in locations ordered by dates
select location, date, total_cases, new_cases, total_deaths, population from CovidDeathsss order by 1,2;

--Total Cases Vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from CovidDeathsss where total_cases != 0 order by location, date;

select continent, max(total_cases) as total_case, max(total_deaths) as total_death, (max(total_deaths)/max(total_cases))*100 as death_percentage
from CovidDeathsss where total_cases != 0 group by continent order by continent;

select location, max(total_cases) as total_case, max(total_deaths) as total_death,(max(total_deaths)/max(total_cases))*100 as death_percentage 
from CovidDeathsss where total_cases != 0 group by location order by location;

--Total Cases Vs Population
select location, date, total_cases, population, (total_cases/population)*100 as cases_percentage 
from CovidDeathsss where population != 0 order by location, date;

select location, max(total_cases) as total_case, max(population), (max(total_cases)/max(population))*100 as cases_percentage
from CovidDeathsss where population != 0 group by location order by location;

--Countries with highest Infection rate
select location, max(total_cases) as total_case, max(population) as pop, (max(total_cases)/max(population))*100 as cases_percentage
from CovidDeathsss where population != 0 group by location order by cases_percentage desc;

--Countries with the highest death count per population
select location, max(total_deaths) as total_death, max(population) as pop, (max(total_deaths)/max(population))*100 as DeathPercentPerPopulation
from CovidDeathsss where population != 0 group by location order by DeathPercentPerPopulation desc;

select location, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths, (max(total_deaths)/max(total_cases))*100 
as DeathPercentPerCases from CovidDeathsss where continent is not null and total_cases != 0 group by location order by 1,2;

--Total Death count in each location
select location, max(cast(total_deaths as int)) as TotalDeathCount from CovidDeathsss where continent is not null 
and location not in ('World', 'European Union', 'International') group by location order by TotalDeathCount desc;

--Breaking things down by continent
select continent, max(total_deaths) as TotalDeathCount 
from CovidDeathsss where continent is not null group by continent order by TotalDeathCount desc;

--Global Numbers
select location, max(total_cases) as TotalCases, max(cast(total_deaths as int)) as TotalDeaths
from CovidDeathsss where continent is not null group by location order by 1,2; 

--Changing Columns types to float type
alter table coviddeathsss alter column total_deaths float;
alter table coviddeathsss alter column total_cases float;
alter table coviddeathsss alter column new_cases float;
alter table coviddeathsss alter column new_deaths float;
alter table coviddeathsss alter column population float;
alter table covidvaccinationns alter column new_vaccinations float;

--Total no of cases and deaths in the world
select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage from CovidDeathsss where continent is not null;

--Total no of cases and deaths in each location
select location, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths from CovidDeathsss group by location order by 1,2

select location, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths, (max(total_deaths)/max(total_cases))*100 as DeathPercentage
from CovidDeathsss group by location having max(total_cases) != 0 order by 1,2; --removed Anguilla and others which has a 0 total_cases

--Performing Joins
select * from CovidDeathsss dea join CovidVaccinationns vac on dea.location = vac.location and dea.date = vac.date;

--Looking at Total Population Vs Total Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from CovidDeathsss dea join CovidVaccinationns vac 
on dea.location = vac.location and dea.date = vac.date where dea.continent is not null order by 1,2,3;

--Using Windows Function: partition by
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from CovidDeathsss dea join CovidVaccinationns vac on 
dea.location = vac.location and dea.date = vac.date where dea.continent is not null order by 1,2,3;

--Using CTE 
with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from CovidDeathsss dea join CovidVaccinationns vac on 
dea.location = vac.location and dea.date = vac.date where dea.continent is not null)
select *, (RollingPeopleVaccinated/population)*100 from PopVsVac where population != 0 order by location;

--TEMP TABLE: performs same query as the  CTE above
drop table if exists #PercentPopulationVaccinated --incase to alterate the  created table, or query in any way
create table #PercentPopulationVaccinated 
(continent varchar(255), location varchar(255), date date, population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric) 

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from CovidDeathsss dea join CovidVaccinationns vac on 
dea.location = vac.location and dea.date = vac.date where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated where population != 0 order by location;

--Creating View to store data for later visualizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over 
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from CovidDeathsss dea join CovidVaccinationns vac on 
dea.location = vac.location and dea.date = vac.date where dea.continent is not null

select * from PercentPopulationVaccinated;