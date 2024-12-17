-- Create profiles table
create table if not exists public.profiles (
    id uuid references auth.users on delete cascade primary key,
    full_name text,
    email text unique,
    avatar_url text,
    created_at timestamptz default timezone('utc'::text, now()) not null,
    updated_at timestamptz default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- Create policies
create policy "Public profiles are viewable by everyone"
    on profiles for select
    using ( true );

create policy "Users can insert their own profile"
    on profiles for insert
    with check ( auth.uid() = id );

create policy "Users can update their own profile"
    on profiles for update
    using ( auth.uid() = id );

-- Create indexes
create index profiles_email_idx on profiles(email);

-- Set up triggers for updated_at
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
    before update on profiles
    for each row
    execute procedure public.handle_updated_at();