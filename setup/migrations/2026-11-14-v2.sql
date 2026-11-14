-- MEDEKO – Dispečing: migrácia v2 (14.11.2026)
-- Len pridáva, nič nemaže. Bezpečné spúšťať opakovane.
-- * users.active – "zmazaný" používateľ sa len skryje (história lístkov ostáva)

alter table public.users add column if not exists active boolean not null default true;

create or replace function public.is_dispecer()
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from users where id=auth.uid() and role='dispecer' and coalesce(active,true))
$$;

-- prihlasovací zoznam: len aktívni používatelia
create or replace function public.login_roster()
returns table(name text, role text, email text)
language sql stable security definer set search_path=public as $$
  select u.name, u.role, u.email from public.users u where coalesce(u.active,true) order by u.role, u.name;
$$;
revoke all on function public.login_roster() from public;
grant execute on function public.login_roster() to anon, authenticated;
