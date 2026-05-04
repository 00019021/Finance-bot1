-- Run this entire script in Supabase → SQL Editor → New query

-- 1. Transactions table
create table if not exists transactions (
  id          uuid    default gen_random_uuid() primary key,
  user_id     uuid    references auth.users(id) on delete cascade not null,
  type        text    not null,
  amount      numeric not null,
  category    text    not null,
  payment     text    not null,
  date        text    not null,
  note        text    default '',
  created_at  timestamptz default now()
);

-- 2. Starting balances table
create table if not exists starting_balances (
  user_id  uuid references auth.users(id) on delete cascade not null,
  month    text    not null,
  payment  text    not null,
  amount   numeric not null default 0,
  primary key (user_id, month, payment)
);

-- 3. Enable Row Level Security (users can only see their own data)
alter table transactions      enable row level security;
alter table starting_balances enable row level security;

-- 4. RLS policies
create policy "Users manage own transactions"
  on transactions for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users manage own balances"
  on starting_balances for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);
