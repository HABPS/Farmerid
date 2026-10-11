-- Supabase > SQL Editor mein ye poora chalayein (ek hi baar).

-- 1) Tables
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  shop_name text,
  mobile text,
  role text not null default 'user' check (role in ('user','admin')),
  status text not null default 'pending' check (status in ('pending','approved','blocked')),
  created_at timestamptz not null default now()
);

create table if not exists public.card_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  farmer_id text,
  farmer_name text,
  mobile text,
  action text,
  created_at timestamptz not null default now()
);

-- 2) Helper functions (RLS mein use hote hain)
create or replace function public.is_admin() returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin' and status = 'approved');
$$;

create or replace function public.is_approved() returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from public.profiles where id = auth.uid() and status = 'approved');
$$;

-- 3) Naya user register hote hi profile apne aap ban jaye (status = pending)
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, shop_name, mobile)
  values (new.id, new.email,
          new.raw_user_meta_data->>'full_name',
          new.raw_user_meta_data->>'shop_name',
          new.raw_user_meta_data->>'mobile');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- 4) Security (Row Level Security)
alter table public.profiles enable row level security;
alter table public.card_logs enable row level security;

drop policy if exists "profiles: apna dekho" on public.profiles;
drop policy if exists "profiles: admin sab dekhe" on public.profiles;
drop policy if exists "profiles: admin badle" on public.profiles;
create policy "profiles: apna dekho" on public.profiles for select using (id = auth.uid());
create policy "profiles: admin sab dekhe" on public.profiles for select using (public.is_admin());
create policy "profiles: admin badle" on public.profiles for update using (public.is_admin()) with check (public.is_admin());
-- Normal user apni role/status khud nahi badal sakta (uske liye update policy hi nahi hai).

drop policy if exists "logs: apna insert" on public.card_logs;
drop policy if exists "logs: apna dekho" on public.card_logs;
drop policy if exists "logs: admin sab dekhe" on public.card_logs;
create policy "logs: apna insert" on public.card_logs for insert with check (user_id = auth.uid() and public.is_approved());
create policy "logs: apna dekho" on public.card_logs for select using (user_id = auth.uid());
create policy "logs: admin sab dekhe" on public.card_logs for select using (public.is_admin());

-- 5) PEHLA ADMIN: pehle site par register karein, phir apni email likh kar ye chalayein:
-- update public.profiles set role = 'admin', status = 'approved' where email = 'AAPKI-EMAIL@example.com';
