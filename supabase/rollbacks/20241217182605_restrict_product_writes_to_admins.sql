-- Rollback for supabase/migrations/20241217182605_restrict_product_writes_to_admins.sql
--
-- Warning: this restores the old behaviour where ANY signed-in user can
-- insert and update products, and it deletes the admin_users table
-- (the list of admins is lost).
--
-- If the migration was applied with the Supabase CLI, also run:
--   supabase migration repair --status reverted 20241217182605

drop policy if exists "Only admins can create products" on public.products;
drop policy if exists "Only admins can update products" on public.products;
drop policy if exists "Only admins can delete products" on public.products;

drop policy if exists "Only authenticated users can create products" on public.products;
create policy "Only authenticated users can create products"
    on products for insert
    with check ( auth.role() = 'authenticated' );

drop policy if exists "Only authenticated users can update products" on public.products;
create policy "Only authenticated users can update products"
    on products for update
    using ( auth.role() = 'authenticated' );

drop function if exists public.is_admin();
drop table if exists public.admin_users;
