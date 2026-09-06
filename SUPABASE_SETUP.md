# Supabase setup

The app ships with the project's Supabase URL and publishable key baked in (`lib/core/config/app_config.dart`), so plain `flutter run` connects automatically. To point at a different project, override them at build/run time:

```powershell
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

Use only the public publishable key in the Flutter app. Never place a Supabase service-role key in source code, app binaries, or client configuration.

Without any credentials the app starts with the local UI foundation and does not attempt a network connection.

## Required tables

Run these in Supabase Dashboard → SQL Editor → New query → Run.

### `showrooms`

```sql
create table if not exists public.showrooms (
  id bigint generated always as identity primary key,
  name text not null,
  address text not null,
  city text not null,
  phone text,
  email text,
  website text,
  description text,
  logo_url text,
  cover_image_url text,
  opening_hours text,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  average_rating numeric not null default 0,
  review_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.showrooms enable row level security;

create policy "admins manage showrooms"
  on public.showrooms for all
  using (
    exists (
      select 1 from public.profiles p
      where p.user_id = auth.uid()
        and p.role in ('admin', 'super_admin')
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.user_id = auth.uid()
        and p.role in ('admin', 'super_admin')
    )
  );

create policy "customers view approved showrooms"
  on public.showrooms for select
  using (status = 'approved');

create index if not exists showrooms_status_idx on public.showrooms (status);
create index if not exists showrooms_city_idx on public.showrooms (city);
```

### `cars`

```sql
create table if not exists public.cars (
  id bigint generated always as identity primary key,
  showroom_id bigint not null references public.showrooms (id) on delete cascade,
  title text not null,
  brand text not null,
  model text,
  year integer,
  price numeric,
  km integer,
  fuel text check (fuel in ('petrol', 'diesel', 'hybrid', 'electric', 'cng')),
  transmission text check (transmission in ('automatic', 'manual')),
  condition text check (condition in ('new', 'used')),
  description text,
  image_url text,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

alter table public.cars enable row level security;

create policy "admins manage cars"
  on public.cars for all
  using (
    exists (
      select 1 from public.profiles p
      where p.user_id = auth.uid()
        and p.role in ('admin', 'super_admin')
    )
  )
  with check (
    exists (
      select 1 from public.profiles p
      where p.user_id = auth.uid()
        and p.role in ('admin', 'super_admin')
    )
  );

create policy "customers view approved cars"
  on public.cars for select
  using (status = 'approved');

create index if not exists cars_showroom_idx on public.cars (showroom_id);
create index if not exists cars_status_idx on public.cars (status);
create index if not exists cars_created_at_idx on public.cars (created_at desc);
```

### `admin_logs`

```sql
create table if not exists public.admin_logs (
  id bigint generated always as identity primary key,
  admin_id uuid,
  action text not null,
  description text,
  created_at timestamptz not null default now()
);

alter table public.admin_logs enable row level security;

create policy "admins view admin_logs"
  on public.admin_logs for select
  using (
    exists (
      select 1 from public.profiles p
      where p.user_id = auth.uid()
        and p.role in ('admin', 'super_admin')
    )
  );

create policy "admins insert admin_logs"
  on public.admin_logs for insert
  with check (
    exists (
      select 1 from public.profiles p
      where p.user_id = auth.uid()
        and p.role in ('admin', 'super_admin')
    )
  );
```

### `reviews` + rating recompute

Run this to create/replace the reviews table, harden its row-level security (customers may only post/read their own or approved reviews; admins can moderate all), and keep each showroom's stored rating in sync via triggers. Use `public.is_admin()` (created earlier for the profiles fix; it checks `profiles.id = auth.uid() AND role in ('admin','super_admin')`).

```sql
create table if not exists public.reviews (
  id bigint generated always as identity primary key,
  showroom_id bigint not null references public.showrooms (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text not null default '',
  status text not null default 'pending' check (status in ('pending', 'approved')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.reviews enable row level security;

do $$
declare p record;
begin
  for p in select policyname from pg_policies where schemaname = 'public' and tablename = 'reviews' loop
    execute format('drop policy %I on public.reviews', p.policyname);
  end loop;
end $$;

create policy "everyone can read approved reviews or their own"
  on public.reviews for select
  using (status = 'approved' or auth.uid() = user_id);

create policy "authenticated users can submit their own pending reviews"
  on public.reviews for insert
  with check (
    auth.uid() = user_id
    and status = 'pending'
    and rating between 1 and 5
  );

create policy "users can edit their own pending reviews"
  on public.reviews for update
  using (auth.uid() = user_id and status = 'pending')
  with check (auth.uid() = user_id and status = 'pending');

create policy "owners and admins can delete reviews"
  on public.reviews for delete
  using (auth.uid() = user_id or public.is_admin());

create policy "admins can manage all reviews"
  on public.reviews for all
  using (public.is_admin())
  with check (public.is_admin());

create or replace function public.refresh_showroom_rating()
returns trigger
language plpgsql
security definer
as $$
declare
  v_showroom_id bigint;
  v_avg numeric;
  v_count integer;
begin
  v_showroom_id := coalesce(new.showroom_id, old.showroom_id);
  select avg(rating), count(*) into v_avg, v_count
    from public.reviews
   where showroom_id = v_showroom_id and status = 'approved';
  if v_count > 0 then
    update public.showrooms
       set average_rating = round(coalesce(v_avg, 0)::numeric, 1),
           review_count = v_count
     where id = v_showroom_id;
  else
    update public.showrooms
       set average_rating = 0.0,
           review_count = 0
     where id = v_showroom_id;
  end if;
  return null;
end $$;

drop trigger if exists reviews_refresh_showroom_rating on public.reviews;
create trigger reviews_refresh_showroom_rating
  after insert or update or delete on public.reviews
  for each row execute function public.refresh_showroom_rating();

create index if not exists reviews_showroom_idx on public.reviews (showroom_id);
create index if not exists reviews_status_idx on public.reviews (status);
```

### Customer signup → auto profile row

Run this so every new email/password signup automatically gets a `profiles` row (id = auth user id, name from `user_metadata.full_name`). Mines existing users who lack a row. Required for My Account to show a name.

```sql
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', '')
  );
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

insert into public.profiles (id, email, full_name)
select u.id, u.email, coalesce(u.raw_user_meta_data->>'full_name', '')
  from auth.users u
  left join public.profiles p on p.id = u.id
 where p.id is null;
```

### Car / showroom images (Storage)

Adds an `image_url` column on `showrooms` and creates two public storage buckets (`car-images`, `showroom-images`) where admins upload car and showroom photos. Public read for everyone; write is limited to admins via `public.is_admin()`.

```sql
alter table public.showrooms
  add column if not exists image_url text;

insert into storage.buckets (id, name, public)
values ('car-images', 'car-images', true),
       ('showroom-images', 'showroom-images', true)
on conflict (id) do nothing;

drop policy if exists "public read car-images" on storage.objects;
drop policy if exists "admin insert car-images" on storage.objects;
drop policy if exists "admin update car-images" on storage.objects;
drop policy if exists "admin delete car-images" on storage.objects;
drop policy if exists "public read showroom-images" on storage.objects;
drop policy if exists "admin insert showroom-images" on storage.objects;
drop policy if exists "admin update showroom-images" on storage.objects;
drop policy if exists "admin delete showroom-images" on storage.objects;

create policy "public read car-images"
  on storage.objects for select
  using (bucket_id = 'car-images');

create policy "admin insert car-images"
  on storage.objects for insert
  with check (bucket_id = 'car-images' and public.is_admin());

create policy "admin update car-images"
  on storage.objects for update
  using (bucket_id = 'car-images' and public.is_admin())
  with check (bucket_id = 'car-images' and public.is_admin());

create policy "admin delete car-images"
  on storage.objects for delete
  using (bucket_id = 'car-images' and public.is_admin());

create policy "public read showroom-images"
  on storage.objects for select
  using (bucket_id = 'showroom-images');

create policy "admin insert showroom-images"
  on storage.objects for insert
  with check (bucket_id = 'showroom-images' and public.is_admin());

create policy "admin update showroom-images"
  on storage.objects for update
  using (bucket_id = 'showroom-images' and public.is_admin())
  with check (bucket_id = 'showroom-images' and public.is_admin());

create policy "admin delete showroom-images"
  on storage.objects for delete
  using (bucket_id = 'showroom-images' and public.is_admin());
```
