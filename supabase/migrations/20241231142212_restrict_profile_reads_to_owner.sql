-- Stop exposing every user's profile.
--
-- "Public profiles are viewable by everyone" used (true), so anyone with the
-- public anon key could list every user's email and phone number.
-- Users can now read only their own profile; admins (public.is_admin()) can
-- read all of them. The app only ever reads the signed-in user's own profile,
-- so nothing needs to stay public. Insert and update policies already limit
-- users to their own row and are unchanged.
--
-- Rollback: supabase/rollbacks/20241231142212_restrict_profile_reads_to_owner.sql

drop policy if exists "Public profiles are viewable by everyone" on public.profiles;

drop policy if exists "Users can view their own profile" on public.profiles;
create policy "Users can view their own profile"
    on public.profiles for select
    to authenticated
    using ( (select auth.uid()) = id );

drop policy if exists "Admins can view all profiles" on public.profiles;
create policy "Admins can view all profiles"
    on public.profiles for select
    to authenticated
    using ( (select public.is_admin()) );
