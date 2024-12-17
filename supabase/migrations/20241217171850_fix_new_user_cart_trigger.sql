-- Fix sign up failing with "Database error saving new user".
--
-- The create_cart_for_new_user trigger on auth.users runs as the Supabase Auth
-- role (supabase_auth_admin), which has no privileges on public.carts, so every
-- sign up was rolled back with "permission denied for table carts".
-- Run the function as its owner (security definer) with an empty search_path,
-- which is the pattern Supabase recommends for triggers on auth.users.
-- The function body is unchanged.
--
-- Rollback: supabase/rollbacks/20241217171850_fix_new_user_cart_trigger.sql

create or replace function public.handle_new_user_cart()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.carts (user_id)
    values (new.id);
    return new;
end;
$$;
