-- Backend for /warsaw2026/: per-user session ratings and photos.
-- Run once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.
-- Safe to re-run.

-- Who may store data: anyone who is signed in. To limit it again, change this
-- function (for example to check an allow-list table); the policies below use it.
create or replace function public.is_allowed()
returns boolean
language sql stable security definer set search_path = ''
as $$
  select auth.uid() is not null;
$$;

-- Earlier versions kept an allow-list of email addresses.
drop table if exists public.allowed_emails;

-- Ratings: one row per user and session.
create table if not exists public.ratings (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  session_key text not null,
  rating smallint not null check (rating between 0 and 3),
  updated_at timestamptz not null default now(),
  primary key (user_id, session_key)
);
alter table public.ratings enable row level security;
drop policy if exists "own ratings" on public.ratings;
create policy "own ratings" on public.ratings for all to authenticated
  using (user_id = auth.uid() and public.is_allowed())
  with check (user_id = auth.uid() and public.is_allowed());

-- Picks: which sessions each person plans to attend. picked = false keeps
-- un-picks so they sync too.
create table if not exists public.picks (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  session_key text not null,
  picked boolean not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, session_key)
);
alter table public.picks enable row level security;
drop policy if exists "own picks" on public.picks;
create policy "own picks" on public.picks for all to authenticated
  using (user_id = auth.uid() and public.is_allowed())
  with check (user_id = auth.uid() and public.is_allowed());

-- Photos: metadata here, image files in the private "photos" bucket under <user id>/.
create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  session_key text not null,
  path text not null,
  created_at timestamptz not null default now()
);
alter table public.photos enable row level security;
drop policy if exists "own photos" on public.photos;
create policy "own photos" on public.photos for all to authenticated
  using (user_id = auth.uid() and public.is_allowed())
  with check (user_id = auth.uid() and public.is_allowed());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "own photo files" on storage.objects;
create policy "own photo files" on storage.objects for all to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text and public.is_allowed())
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text and public.is_allowed());
