-- Rollback for supabase/migrations/20241231142212_restrict_profile_reads_to_owner.sql
--
-- Warning: this makes every profile (including email and phone) readable by
-- anyone again, signed in or not.
--
-- If the migration was applied with the Supabase CLI, also run:
--   supabase migration repair --status reverted 20241231142212

drop policy if exists "Users can view their own profile" on public.profiles;
drop policy if exists "Admins can view all profiles" on public.profiles;

drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
create policy "Public profiles are viewable by everyone"
    on profiles for select
    using ( true );
