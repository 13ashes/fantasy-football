update staging.matchups
set team_1_points = 130
where id = 3181;

update staging.matchups
set team_2_points = 130
where id = 3165;

update staging.teams
set rank = 1
where id = 158;

update staging.teams
set rank = 2
where id = 157;