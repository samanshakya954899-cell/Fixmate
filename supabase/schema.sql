create extension if not exists pgcrypto;

create type public.user_role as enum ('customer', 'provider', 'admin');
create type public.booking_type as enum ('direct', 'open');
create type public.booking_status as enum (
  'pending',
  'accepted',
  'in_progress',
  'completed',
  'cancelled',
  'rejected'
);
create type public.offer_status as enum ('pending', 'accepted', 'rejected');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text,
  city text,
  address text,
  avatar_url text,
  roles public.user_role[] not null default array['customer']::public.user_role[],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.provider_profiles (
  id uuid primary key references public.profiles(id) on delete cascade,
  business_name text not null default '',
  bio text,
  experience_years int not null default 0 check (experience_years >= 0),
  service_area text not null default '',
  is_available boolean not null default true,
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.service_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  icon_name text not null default 'build',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.provider_services (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  category_id uuid not null references public.service_categories(id),
  title text not null,
  description text,
  base_charge numeric(10, 2) not null default 0 check (base_charge >= 0),
  city text not null default '',
  service_area text not null default '',
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.booking_requests (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles(id) on delete cascade,
  provider_id uuid references public.provider_profiles(id) on delete set null,
  category_id uuid not null references public.service_categories(id),
  provider_service_id uuid references public.provider_services(id) on delete set null,
  booking_type public.booking_type not null default 'open',
  status public.booking_status not null default 'pending',
  issue_description text not null,
  address text not null,
  city text not null default '',
  preferred_at timestamptz,
  quoted_charge numeric(10, 2),
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.booking_offers (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.booking_requests(id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  message text,
  charge numeric(10, 2) not null default 0 check (charge >= 0),
  status public.offer_status not null default 'pending',
  created_at timestamptz not null default now(),
  unique (booking_id, provider_id)
);

create table public.chats (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.booking_requests(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create table public.ratings (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.booking_requests(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(id) on delete cascade,
  stars int not null check (stars between 1 and 5),
  review text,
  created_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger provider_profiles_set_updated_at
before update on public.provider_profiles
for each row execute function public.set_updated_at();

create trigger provider_services_set_updated_at
before update on public.provider_services
for each row execute function public.set_updated_at();

create trigger booking_requests_set_updated_at
before update on public.booking_requests
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, roles)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    array['customer']::public.user_role[]
  );
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

insert into public.service_categories (name, description, icon_name)
values
  ('TV', 'TV repair and installation', 'tv'),
  ('Freezer', 'Freezer repair and cooling issues', 'kitchen'),
  ('Cooler', 'Air cooler repair and servicing', 'air'),
  ('AC', 'AC repair, gas refill and servicing', 'ac_unit'),
  ('Other', 'Other home appliance repair services', 'build')
on conflict (name) do nothing;

alter table public.profiles enable row level security;
alter table public.provider_profiles enable row level security;
alter table public.service_categories enable row level security;
alter table public.provider_services enable row level security;
alter table public.booking_requests enable row level security;
alter table public.booking_offers enable row level security;
alter table public.chats enable row level security;
alter table public.chat_messages enable row level security;
alter table public.ratings enable row level security;
alter table public.notifications enable row level security;

create policy "profiles are readable by signed in users"
on public.profiles for select to authenticated
using (true);

create policy "users update own profile"
on public.profiles for update to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "provider profiles are public to signed in users"
on public.provider_profiles for select to authenticated
using (true);

create policy "users manage own provider profile"
on public.provider_profiles for all to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "categories are readable"
on public.service_categories for select to authenticated
using (is_active = true);

create policy "provider services are readable"
on public.provider_services for select to authenticated
using (is_available = true);

create policy "providers manage own services"
on public.provider_services for all to authenticated
using (provider_id = auth.uid())
with check (provider_id = auth.uid());

create policy "customers create bookings"
on public.booking_requests for insert to authenticated
with check (customer_id = auth.uid());

create policy "participants read bookings"
on public.booking_requests for select to authenticated
using (
  customer_id = auth.uid()
  or provider_id = auth.uid()
  or booking_type = 'open'
);

create policy "customers update own pending bookings"
on public.booking_requests for update to authenticated
using (customer_id = auth.uid())
with check (customer_id = auth.uid());

create policy "providers update assigned or open bookings"
on public.booking_requests for update to authenticated
using (provider_id = auth.uid() or booking_type = 'open')
with check (provider_id = auth.uid() or booking_type = 'open');

create policy "participants read offers"
on public.booking_offers for select to authenticated
using (
  provider_id = auth.uid()
  or exists (
    select 1 from public.booking_requests br
    where br.id = booking_id and br.customer_id = auth.uid()
  )
);

create policy "providers create own offers"
on public.booking_offers for insert to authenticated
with check (provider_id = auth.uid());

create policy "providers update own offers"
on public.booking_offers for update to authenticated
using (provider_id = auth.uid())
with check (provider_id = auth.uid());

create policy "chat participants read chats"
on public.chats for select to authenticated
using (customer_id = auth.uid() or provider_id = auth.uid());

create policy "chat participants create chats"
on public.chats for insert to authenticated
with check (customer_id = auth.uid() or provider_id = auth.uid());

create policy "chat participants read messages"
on public.chat_messages for select to authenticated
using (
  exists (
    select 1 from public.chats c
    where c.id = chat_id
    and (c.customer_id = auth.uid() or c.provider_id = auth.uid())
  )
);

create policy "chat participants send messages"
on public.chat_messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.chats c
    where c.id = chat_id
    and (c.customer_id = auth.uid() or c.provider_id = auth.uid())
  )
);

create policy "participants read ratings"
on public.ratings for select to authenticated
using (customer_id = auth.uid() or provider_id = auth.uid());

create policy "customers rate completed bookings"
on public.ratings for insert to authenticated
with check (
  customer_id = auth.uid()
  and exists (
    select 1 from public.booking_requests br
    where br.id = booking_id
    and br.customer_id = auth.uid()
    and br.status = 'completed'
  )
);

create policy "users read own notifications"
on public.notifications for select to authenticated
using (user_id = auth.uid());

create policy "users update own notifications"
on public.notifications for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());
