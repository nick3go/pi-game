-- PI LAB: enkratna namestitev v obstoječem Supabase projektu.
-- Ne briše in ne spreminja shem timeline_private, g4a_private ali njunih podatkov.
-- Namenoma uporabljamo samo public RPC funkcije, ker je pi_private zasebna shema.
begin;
create schema if not exists pi_private;
revoke all on schema pi_private from public, anon, authenticated;
create table if not exists pi_private.profiles (
  name text primary key,
  best_score integer not null default 0 check (best_score between 0 and 1500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint pi_profile_name_check check (name ~ '^[a-z0-9_-]{3,24}$')
);
revoke all on all tables in schema pi_private from public, anon, authenticated;
alter table pi_private.profiles enable row level security;

-- PUBLIC RPC interface: namenoma samo vzdevek, brez gesel ali tajnih ključev.
-- Opozorilo: identiteta ni preverjena. Kdorkoli z istim vzdevkom lahko posodobi rekord.
create or replace function public.pi_profile_get(p_name text)
returns integer language plpgsql security definer
set search_path = '' as $$
declare result integer;
begin
  if p_name is null or p_name !~ '^[a-z0-9_-]{3,24}$' then
    raise exception 'Neveljaven vzdevek';
  end if;
  select best_score into result from pi_private.profiles where name = p_name;
  return result;
end; $$;

create or replace function public.pi_profile_create(p_name text)
returns integer language plpgsql security definer
set search_path = '' as $$
declare result integer;
begin
  if p_name is null or p_name !~ '^[a-z0-9_-]{3,24}$' then
    raise exception 'Neveljaven vzdevek';
  end if;
  insert into pi_private.profiles(name) values (p_name)
  on conflict (name) do nothing;
  select best_score into result from pi_private.profiles where name = p_name;
  return result;
end; $$;

create or replace function public.pi_record_attempt(p_name text, p_score integer)
returns integer language plpgsql security definer
set search_path = '' as $$
declare result integer;
begin
  if p_name is null or p_name !~ '^[a-z0-9_-]{3,24}$'
     or p_score is null or p_score < 0 or p_score > 1500 then
    raise exception 'Neveljaven vzdevek ali rezultat';
  end if;
  update pi_private.profiles
     set best_score = greatest(best_score, p_score),
         updated_at = case when p_score > best_score then now() else updated_at end
   where name = p_name
  returning best_score into result;
  if result is null then
    raise exception 'Profil ne obstaja';
  end if;
  return result;
end; $$;

revoke all on function public.pi_profile_get(text) from public;
revoke all on function public.pi_profile_create(text) from public;
revoke all on function public.pi_record_attempt(text,integer) from public;
grant execute on function public.pi_profile_get(text) to anon, authenticated;
grant execute on function public.pi_profile_create(text) to anon, authenticated;
grant execute on function public.pi_record_attempt(text,integer) to anon, authenticated;
commit;
