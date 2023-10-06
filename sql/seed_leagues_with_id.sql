alter table public.leagues add column league_id INTEGER;
update public.leagues
set league_id = 1
where name like '%IC%' or name like '%Iowa City%';

update public.leagues
set league_id = 2
where name like '%Alien Ass%';

update public.leagues
set league_id = 3
where name like '%Kuz%';

update public.leagues
set league_id = 5
where name like '%Dynasty%';

update public.leagues
set league_id = -1
where name like '%fake%' or name like '%The Spaghetti%';

update public.leagues
set league_id = 4
where name like '%Libertyville%' or name like '%Mayberry%' or name like '%mike is in charge%';