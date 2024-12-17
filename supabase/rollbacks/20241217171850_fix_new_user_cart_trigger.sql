-- Rollback for supabase/migrations/20241217171850_fix_new_user_cart_trigger.sql
--
-- Restores the original handle_new_user_cart() definition from
-- 20240101000002_create_cart_tables.sql (security invoker, no search_path).
-- Warning: with this definition sign ups fail again with
-- "Database error saving new user".
--
-- If the migration was applied with the Supabase CLI, also run:
--   supabase migration repair --status reverted 20241217171850

create or replace function public.handle_new_user_cart()
returns trigger as $$
begin
    insert into public.carts (user_id)
    values (new.id);
    return new;
end;
$$ language plpgsql;
