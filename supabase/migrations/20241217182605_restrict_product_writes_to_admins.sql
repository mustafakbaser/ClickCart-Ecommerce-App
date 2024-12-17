-- Restrict product writes to admins.
--
-- The previous policies only checked auth.role() = 'authenticated', so any
-- signed-in user could insert or update products straight through the API.
-- Admins are now listed in public.admin_users. That table has RLS enabled and
-- no policies, and the API roles have no privileges on it, so it can only be
-- changed from the SQL editor or with the service role key.
-- Reading products stays public ("Products are viewable by everyone").
--
-- Make a user an admin (SQL editor):
--   insert into public.admin_users (user_id)
--   select id from auth.users where email = 'admin@example.com';
--
-- Rollback: supabase/rollbacks/20241217182605_restrict_product_writes_to_admins.sql

create table if not exists public.admin_users (
    user_id uuid references auth.users on delete cascade primary key,
    created_at timestamptz default timezone('utc'::text, now()) not null
);

alter table public.admin_users enable row level security;

revoke all on table public.admin_users from anon, authenticated;

-- Runs as the function owner so policies can check admin_users without
-- giving API roles access to the table. Only answers for the calling user.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1 from public.admin_users
        where user_id = auth.uid()
    );
$$;

revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

-- Replace the "any authenticated user" write policies
drop policy if exists "Only authenticated users can create products" on public.products;
drop policy if exists "Only authenticated users can update products" on public.products;

drop policy if exists "Only admins can create products" on public.products;
create policy "Only admins can create products"
    on public.products for insert
    to authenticated
    with check ( (select public.is_admin()) );

drop policy if exists "Only admins can update products" on public.products;
create policy "Only admins can update products"
    on public.products for update
    to authenticated
    using ( (select public.is_admin()) )
    with check ( (select public.is_admin()) );

drop policy if exists "Only admins can delete products" on public.products;
create policy "Only admins can delete products"
    on public.products for delete
    to authenticated
    using ( (select public.is_admin()) );
