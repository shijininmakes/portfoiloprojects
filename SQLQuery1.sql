select *
From [portfolio project]..CovidDeaths
where continent is not null
ORDER BY 3,4

/*select *
From [portfolio project]..CovidVaccinations
ORDER BY 3,4*/

select Location,date,total_cases,new_cases,total_deaths,population
From [portfolio project]..CovidDeaths
where continent is not null
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--show the likely hood if you contract covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths
Where location like '%india%'
and continent is not null
ORDER BY 1,2

--looking
select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [portfolio project]..CovidDeaths
--Where location like '%india%'
ORDER BY 1,2

--looking at countries with highest infection rate
select Location,population,MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project]..CovidDeaths
--Where location like '%india%'
Group by location,population
ORDER BY PercentPopulationInfected desc

--showing countries highest death count
select Location,MAX(cast(total_deaths as int)) as TotalDeathcounts
From [portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by location
ORDER BY TotalDeathcounts desc

--LET'S BREAK THINGS DOWN BY CONTIENT
select continent,MAX(cast(total_deaths as int)) as TotalDeathcounts
From [portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by continent
ORDER BY TotalDeathcounts desc

--showing contient with highest death count
select continent,MAX(cast(total_deaths as int)) as TotalDeathcounts
From [portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is not null
Group by continent
ORDER BY TotalDeathcounts desc

--global numbers
select SUM(new_cases)as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(New_deaths as int ))/SUM(new_cases) *100 as DeathPercentage
From [portfolio project]..CovidDeaths
--Where location like '%india%'
where continent is not null
--Group by date
ORDER BY 1,2

-- total population v/s vaccations
--use cte
with popvsVac(continent,location,Date,population,New_Vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated

From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/Population)*100
From popvsVac

--temp
Drop  Table if exists #percentpopulationvaccinated
create  table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into  #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated

From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(Rollingpeoplevaccinated/Population)*100
From  #percentpopulationvaccinated
--creating view to storedata
create view percentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated

From [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
From percentPopulationVaccinated



