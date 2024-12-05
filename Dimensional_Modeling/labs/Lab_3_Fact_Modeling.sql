create table fct_game_details (
        dim_game_date DATE,
        dim_season INTEGER,
        dim_team_id INTEGER,
        dim_player_id INTEGER,
        dim_player_name TEXT,
        dim_start_position TEXT,
        dim_is_playing_at_home BOOLEAN,
        dim_did_not_play BOOLEAN,
        dim_did_not_dress BOOLEAN,
        dim_not_with_team BOOLEAN,
        m_minutes REAL,
        m_fgm INTEGER,
        m_fga INTEGER,
        m_fg3m INTEGER,
        m_fg3a INTEGER,
        m_ftm INTEGER,
        m_fta INTEGER,
        m_oreb INTEGER,
        m_dreb INTEGER,
        m_reb INTEGER,
        m_ast INTEGER,
        m_stl INTEGER,
        m_blk INTEGER,
        m_turnovers INTEGER,
        m_pf INTEGER,
        m_pts INTEGER,
        plus_minus INTEGER
        
);


INSERT INTO fct_game_details
with deduped as (
select g.game_date_est, 
g.season,
g.home_team_id,
g.visitor_team_id,
 gd.*, 
 row_number()over(partition by gd.game_id, team_id, player_id order by g.game_date_est) as row_num
 from game_details gd
 join games g on gd.game_id = g.game_id
 where g.game_date_est = '2016-10-04'
 )
 select 
 game_date_est as dim_game_date,
 season as dim_season,
 team_id as dim_team_id,
 player_id as dim_player_id, 
 player_name as dim_player_name,
 start_position,
 team_id = home_team_id as dim_is_playing_at_home,
 coalesce(position('DNP' in comment),0)>0 as dim_did_not_play,
 coalesce(position('DND' in comment),0)>0 as dim_did_not_dress,
 coalesce(position('NWT' in comment),0)>0 as dim_not_with_team,
 CAST(SPLIT_PART(min, ':',1) AS REAL) + CAST(SPLIT_PART(min, ':',2) AS REAL)/60 AS minutes,
 fgm,
 fga,
 fg3m,
 fg3a,
 ftm,
 fta,
 oreb,
 dreb,
 reb,
 ast,
 stl,
 blk,
 "TO" AS turnovers,
 pf,
 pts,
 plus_minus
 from deduped
 where row_num = 1;

 select * from fct_game_details;
 