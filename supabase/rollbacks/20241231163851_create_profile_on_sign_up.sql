-- Rollback for supabase/migrations/20241231163851_create_profile_on_sign_up.sql
--
-- Removes the trigger and function. Profiles created by the trigger or by the
-- backfill are kept (they are ordinary user data). Revert the app code too:
-- after this rollback signUp() no longer creates a profile at all.
--
-- If the migration was applied with the Supabase CLI, also run:
--   supabase migration repair --status reverted 20241231163851

drop trigger if exists create_profile_for_new_user on auth.users;
drop function if exists public.handle_new_user_profile();
