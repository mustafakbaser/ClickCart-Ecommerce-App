-- Rollback for supabase/migrations/20241231150947_create_orders_server_side.sql
--
-- Warning: this lets the browser insert orders and order items directly again,
-- with client-supplied prices and totals. Revert the app code too
-- (orderService.createOrder calls the create_order RPC).
--
-- If the migration was applied with the Supabase CLI, also run:
--   supabase migration repair --status reverted 20241231150947

drop function if exists public.create_order(jsonb, jsonb, text, text);

drop policy if exists "Users can insert their own orders" on public.orders;
create policy "Users can insert their own orders"
    on orders for insert
    with check (auth.uid() = user_id);

drop policy if exists "Users can insert their order items" on public.order_items;
create policy "Users can insert their order items"
    on order_items for insert
    with check (
        exists (
            select 1 from orders
            where orders.id = order_items.order_id
            and orders.user_id = auth.uid()
        )
    );
