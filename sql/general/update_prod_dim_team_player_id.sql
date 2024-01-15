UPDATE prod.dim_team
SET player_id = CASE team_key
WHEN '' THEN 9
WHERE player_id is null;