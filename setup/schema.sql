-- MEDEKO – Dispečing: kompletné schéma (čistá inštalácia, bez ukážkových údajov)
-- Spustiť v Supabase: SQL Editor → New query → vložiť celý súbor → Run
-- Bezpečné spúšťať opakovane (IF NOT EXISTS / CREATE OR REPLACE).

-- ========== tabuľky ==========
create table if not exists public.users(
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null unique,
  role text not null check (role in ('dispecer','vodic')),
  spz text,
  email text not null unique
);
comment on table public.users is 'Profil; heslá sú bcrypt hash v auth.users (Supabase Auth)';

create table if not exists public.slips(
  id bigserial primary key,
  date date not null default current_date,
  spz text default '',
  driver_id uuid references public.users(id),
  note text default '',
  created_at timestamptz default now(),
  deleted_at timestamptz
);

create table if not exists public.tasks(
  id bigserial primary key,
  slip_id bigint not null references public.slips(id) on delete cascade,
  ord int not null check (ord between 1 and 5),
  text text default '',
  weight text default '',
  sale_note text default '',
  placed text default '',
  removed text default '',
  time_from text default '',
  time_to text default '',
  status text not null default 'nova' check (status in ('nova','prebieha','hotovo')),
  updated_at timestamptz default now(),
  deleted_at timestamptz,
  unique(slip_id,ord)
);

create table if not exists public.messages(
  id bigserial primary key,
  task_id bigint not null references public.tasks(id) on delete cascade,
  author_id uuid references public.users(id) default auth.uid(),
  text text default '',
  photo_url text,
  audio_url text,
  lat double precision,
  lng double precision,
  created_at timestamptz default now(),
  deleted_at timestamptz
);

create table if not exists public.positions(
  driver_id uuid primary key references public.users(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  ts timestamptz default now()
);

create table if not exists public.settings(
  key text primary key,
  value jsonb not null,
  updated_at timestamptz default now()
);

create table if not exists public.audit_log(
  id bigserial primary key,
  ts timestamptz not null default now(),
  table_name text not null,
  op text not null,
  row_id bigint,
  actor uuid default auth.uid(),
  old_row jsonb,
  new_row jsonb
);
create index if not exists audit_log_row on public.audit_log(table_name, row_id);

-- ========== predvolené nastavenia ==========
insert into public.settings(key,value) values
  ('retention', '{"db_months":24,"media_months":12,"auto_delete":false}'::jsonb),
  ('rules', '["Pred odchodom skontrolujte zadanie úlohy.","Po dokončení úlohy doplňte všetky údaje (čas, hmotnosť, čísla).","Pri nejasnostiach volajte dispečera.","Dodržiavajte bezpečnostné pokyny na pracovisku.","Nezabudnite označiť úlohu ako hotovú."]'::jsonb)
on conflict (key) do nothing;

-- ========== RLS pomocné funkcie ==========
create or replace function public.is_dispecer()
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from users where id=auth.uid() and role='dispecer')
$$;

create or replace function public.my_slip(sid bigint)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from slips where id=sid and driver_id=auth.uid() and deleted_at is null)
$$;

create or replace function public.my_task(tid bigint)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(
    select 1 from tasks t join slips s on s.id=t.slip_id
    where t.id=tid and s.driver_id=auth.uid() and s.deleted_at is null
  )
$$;

grant execute on function public.is_dispecer(), public.my_slip(bigint), public.my_task(bigint) to authenticated;

-- Zoznam mien na prihlasovacej obrazovke (bez hesiel). Anon môže čítať, aby sa zoznam aktualizoval.
create or replace function public.login_roster()
returns table(name text, role text, email text)
language sql stable security definer set search_path=public as $$
  select u.name, u.role, u.email from public.users u order by u.role, u.name;
$$;
revoke all on function public.login_roster() from public;
grant execute on function public.login_roster() to anon, authenticated;

-- Keep-alive: bezplatný projekt Supabase sa po ~7 dňoch nečinnosti uspí.
-- Volá sa z GitHub Actions (alebo ručne) raz denne.
create or replace function public.keepalive()
returns timestamptz language sql stable security definer set search_path=public as $$
  select now()
$$;
revoke all on function public.keepalive() from public;
grant execute on function public.keepalive() to anon, authenticated;

-- ========== oprávnenia a RLS ==========
alter table public.users enable row level security;
alter table public.slips enable row level security;
alter table public.tasks enable row level security;
alter table public.messages enable row level security;
alter table public.positions enable row level security;
alter table public.settings enable row level security;
alter table public.audit_log enable row level security;

grant select,insert,update,delete on public.users, public.slips, public.tasks, public.messages, public.positions to authenticated;
grant select,insert,update on public.settings to authenticated;
grant usage, select on all sequences in schema public to authenticated;
revoke all on public.users, public.slips, public.tasks, public.messages, public.positions, public.settings, public.audit_log from anon;
revoke all on public.audit_log from authenticated;
grant select on public.audit_log to authenticated;

-- zrušiť prípadné staré všeobecné politiky
drop policy if exists auth_all on public.users;
drop policy if exists auth_all on public.slips;
drop policy if exists auth_all on public.tasks;
drop policy if exists auth_all on public.messages;
drop policy if exists auth_all on public.positions;

drop policy if exists u_sel on public.users;
create policy u_sel on public.users for select to authenticated using (true);
drop policy if exists u_disp on public.users;
create policy u_disp on public.users for update to authenticated using (is_dispecer()) with check (is_dispecer());

drop policy if exists s_disp on public.slips;
create policy s_disp on public.slips for all to authenticated using (is_dispecer()) with check (is_dispecer());
drop policy if exists s_drv on public.slips;
create policy s_drv on public.slips for select to authenticated using (driver_id=auth.uid() and deleted_at is null);

drop policy if exists t_disp on public.tasks;
create policy t_disp on public.tasks for all to authenticated using (is_dispecer()) with check (is_dispecer());
drop policy if exists t_drv_sel on public.tasks;
create policy t_drv_sel on public.tasks for select to authenticated using (my_slip(slip_id) and deleted_at is null);
drop policy if exists t_drv_upd on public.tasks;
create policy t_drv_upd on public.tasks for update to authenticated using (my_slip(slip_id)) with check (my_slip(slip_id));

drop policy if exists m_disp on public.messages;
create policy m_disp on public.messages for all to authenticated using (is_dispecer()) with check (is_dispecer());
drop policy if exists m_drv_sel on public.messages;
create policy m_drv_sel on public.messages for select to authenticated using (my_task(task_id));
drop policy if exists m_drv_ins on public.messages;
create policy m_drv_ins on public.messages for insert to authenticated with check (my_task(task_id) and author_id=auth.uid());

drop policy if exists p_disp on public.positions;
create policy p_disp on public.positions for select to authenticated using (is_dispecer());
drop policy if exists p_own on public.positions;
create policy p_own on public.positions for all to authenticated using (driver_id=auth.uid()) with check (driver_id=auth.uid());

drop policy if exists st_sel on public.settings;
create policy st_sel on public.settings for select to authenticated using (true);
drop policy if exists st_disp on public.settings;
create policy st_disp on public.settings for all to authenticated using (is_dispecer()) with check (is_dispecer());

drop policy if exists a_disp on public.audit_log;
create policy a_disp on public.audit_log for select to authenticated using (is_dispecer());

-- ========== stráže, audit, mäkké mazanie ==========
create or replace function public.tasks_guard() returns trigger
language plpgsql security definer set search_path=public as $$
begin
  if not is_dispecer() then
    if new.slip_id<>old.slip_id or new.ord<>old.ord or new.text is distinct from old.text then
      raise exception 'Vodič nemôže meniť zadanie úlohy';
    end if;
  end if;
  return new;
end $$;
drop trigger if exists tasks_guard on public.tasks;
create trigger tasks_guard before update on public.tasks for each row execute function public.tasks_guard();

create or replace function public.audit_trg() returns trigger
language plpgsql security definer set search_path=public as $$
begin
  insert into audit_log(table_name,op,row_id,actor,old_row,new_row)
  values(
    TG_TABLE_NAME, TG_OP,
    coalesce((case when TG_OP='DELETE' then old.id else new.id end), null),
    auth.uid(),
    case when TG_OP<>'INSERT' then to_jsonb(old) end,
    case when TG_OP<>'DELETE' then to_jsonb(new) end
  );
  return null;
end $$;

create or replace function public.soft_delete_trg() returns trigger
language plpgsql security definer set search_path=public as $$
begin
  if coalesce(current_setting('app.hard_delete', true),'')='on' then return old; end if;
  execute format('update public.%I set deleted_at=now() where id=$1 and deleted_at is null', TG_TABLE_NAME) using old.id;
  return null;
end $$;

do $$ declare t text; begin
  foreach t in array array['slips','tasks','messages'] loop
    execute format('drop trigger if exists audit on public.%I', t);
    execute format('create trigger audit after insert or update or delete on public.%I for each row execute function public.audit_trg()', t);
    execute format('drop trigger if exists soft_delete on public.%I', t);
    execute format('create trigger soft_delete before delete on public.%I for each row execute function public.soft_delete_trg()', t);
  end loop;
end $$;

-- ========== realtime ==========
alter table public.tasks replica identity full;
alter table public.messages replica identity full;
alter table public.slips replica identity full;
alter table public.positions replica identity full;
do $$ declare t text; begin
  foreach t in array array['slips','tasks','messages','positions'] loop
    if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename=t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- ========== úložisko fotiek a hlasových správ ==========
insert into storage.buckets(id,name,public,file_size_limit)
  values('media','media',true,10485760)
on conflict (id) do nothing;
drop policy if exists media_ins on storage.objects;
create policy media_ins on storage.objects for insert to authenticated with check (bucket_id='media');
drop policy if exists media_sel on storage.objects;
create policy media_sel on storage.objects for select to authenticated using (bucket_id='media');
