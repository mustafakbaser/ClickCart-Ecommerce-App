-- Create orders on the server, from the cart, using database prices.
--
-- Orders used to be inserted by the browser with a client-computed total and
-- client-supplied item prices, so a user could pay any amount they liked.
-- public.create_order() now builds the order from the signed-in user's cart:
-- item prices come from public.products, and shipping, 18% tax and the total
-- are computed here. The cart is emptied in the same transaction.
-- Direct inserts into orders/order_items are no longer allowed, so this
-- function is the only way to place an order.
--
-- Keep the shipping prices in sync with getShippingMethods() in
-- src/services/checkoutService.ts (used for display only).
--
-- Rollback: supabase/rollbacks/20241231150947_create_orders_server_side.sql

create or replace function public.create_order(
    p_shipping_address jsonb,
    p_billing_address jsonb,
    p_shipping_method text,
    p_payment_method text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_user_id uuid := auth.uid();
    v_cart_id uuid;
    v_subtotal numeric(10,2);
    v_shipping numeric(10,2);
    v_order_id uuid;
begin
    if v_user_id is null then
        raise exception 'Not authenticated' using errcode = '28000';
    end if;

    v_shipping := case p_shipping_method
        when 'standard' then 9.99
        when 'express' then 19.99
        when 'free' then 0
    end;
    if v_shipping is null then
        raise exception 'Unknown shipping method: %', p_shipping_method using errcode = '22023';
    end if;

    if p_payment_method is null or p_payment_method not in ('credit_card', 'bank_transfer') then
        raise exception 'Unknown payment method: %', p_payment_method using errcode = '22023';
    end if;

    if p_shipping_address is null or p_billing_address is null then
        raise exception 'Shipping and billing address are required' using errcode = '22023';
    end if;

    -- Lock the cart so a double submit cannot create two orders from it
    select id into v_cart_id
    from public.carts
    where user_id = v_user_id
    for update;

    select sum(p.price * ci.quantity) into v_subtotal
    from public.cart_items ci
    join public.products p on p.id = ci.product_id
    where ci.cart_id = v_cart_id;

    if v_subtotal is null then
        raise exception 'Cart is empty' using errcode = '22023';
    end if;

    insert into public.orders (user_id, total, shipping_address, billing_address, shipping_method, payment_method, status)
    values (
        v_user_id,
        round(v_subtotal + v_shipping + v_subtotal * 0.18, 2),
        p_shipping_address,
        p_billing_address,
        p_shipping_method,
        p_payment_method,
        'pending'
    )
    returning id into v_order_id;

    insert into public.order_items (order_id, product_id, quantity, price)
    select v_order_id, ci.product_id::text, ci.quantity, p.price
    from public.cart_items ci
    join public.products p on p.id = ci.product_id
    where ci.cart_id = v_cart_id;

    delete from public.cart_items
    where cart_id = v_cart_id;

    return v_order_id;
end;
$$;

revoke execute on function public.create_order(jsonb, jsonb, text, text) from public, anon;
grant execute on function public.create_order(jsonb, jsonb, text, text) to authenticated;

-- Orders can only be created through create_order()
drop policy if exists "Users can insert their own orders" on public.orders;
drop policy if exists "Users can insert their order items" on public.order_items;
