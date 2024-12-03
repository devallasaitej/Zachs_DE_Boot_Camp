select * from player_seasons;

create type season_stats as (
season integer,
gp integer,
pts real,
reb real,
ast real
);

create type scoring_class as enum ('star','good','average','bad');

create table players (
player_name text,
height text,
college text,
country text,
draft_year text,
draft_round text,
draft_number text,
season_stats season_stats[],
scoring_class scoring_class,
years_since_last_season integer, 
current_season integer, 
primary key(player_name, current_season));

insert into players
with prev as (
select * from players where current_season = 1998
), cur as (
select * from player_seasons where season = 1999)
select coalesce(c.player_name, p.player_name) player_name,
coalesce(c.height, p.height) height,
coalesce(c.college, p.college) college,
coalesce(c.country, p.country) country,
coalesce(c.draft_year, p.draft_year) draft_year,
coalesce(c.draft_round, p.draft_round) draft_round,
coalesce(c.draft_number, p.draft_number) draft_number,
case when p.season_stats is null then array[row(c.season, c.gp, c.pts, c.reb, c.ast):: season_stats]
when c.season is not null then p.season_stats || array[row(c.season, c.gp, c.pts, c.reb, c.ast)::season_stats]
else p.season_stats end as season_stats,
case when c.season is not null then
        case when c.pts > 20 then 'star'
        when c.pts > 15 then 'good'
        when c.pts > 10 then 'average'
        else 'bad' end :: scoring_class 
 else p.scoring_class end as scoring_class,
case when c.season is not null then 0 
else coalesce(p.years_since_last_season, 0)+1 end as years_since_last_season,
coalesce(c.season, p.current_season+1) as current_season
from cur c full outer join prev p
on c.player_name = p.player_name;

with unnested as (
select player_name, 
unnest(season_stats) as season_stats
from players where player_name = 'Michael Jordan' and current_season = 2001
)
select player_name, (season_stats::season_stats).* from unnested;

select player_name, 
(season_stats[cardinality(season_stats)]::season_stats).pts/
case when (season_stats[1]::season_stats).pts = 0 then 1 else (season_stats[1]::season_stats).pts end
from players where current_season = 1999

