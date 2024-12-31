-- Create the profile row in the database when a user signs up.
--
-- The app inserted the profile from the browser right after signUp(). With
-- email confirmation on (the Supabase default), signUp() returns no session,
-- so that insert ran as anon and RLS rejected it: sign up showed an error and
-- the user ended up without a profile.
-- A trigger on auth.users now creates the profile from the sign up metadata
-- (full_name) and email, running as the function owner like the cart trigger.
-- Users who are already missing a profile get one now.
--
-- Rollback: supabase/rollbacks/20241231163851_create_profile_on_sign_up.sql

create or replace function public.handle_new_user_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.profiles (id, full_name, email)
    values (new.id, new.raw_user_meta_data ->> 'full_name', new.email)
    on conflict do nothing;
    return new;
end;
$$;

drop trigger if exists create_profile_for_new_user on auth.users;
create trigger create_profile_for_new_user
    after insert on auth.users
    for each row
    execute function public.handle_new_user_profile();

-- Backfill users whose profile insert was rejected before this fix
insert into public.profiles (id, full_name, email)
select u.id, u.raw_user_meta_data ->> 'full_name', u.email
from auth.users u
where not exists (
    select 1 from public.profiles p where p.id = u.id
)
on conflict do nothing;
