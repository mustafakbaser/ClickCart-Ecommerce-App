import { supabase } from '../lib/supabase';
import { Order } from '../types/profile';
import type { Json } from '../lib/database.types';

export async function getOrders(userId: string): Promise<Order[]> {
  try {
    // First fetch orders
    const { data: orders, error: ordersError } = await supabase
      .from('orders')
      .select('id, user_id, total, status, created_at, shipping_address, shipping_method')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (ordersError) throw ordersError;
    if (!orders) return [];

    // Then fetch order items for each order
    const ordersWithItems = await Promise.all(
      orders.map(async (order) => {
        const { data: items, error: itemsError } = await supabase
          .from('order_items')
          .select('product_id, quantity, price')
          .eq('order_id', order.id);

        if (itemsError) throw itemsError;

        return {
          ...order,
          items: items || []
        };
      })
    );

    return ordersWithItems;
  } catch (error) {
    console.error('Error fetching orders:', error);
    return [];
  }
}

// Orders are created by the create_order() database function from the
// signed-in user's cart: prices, shipping, tax and the total are computed on
// the server, and the cart is emptied in the same transaction.
export async function createOrder(orderData: {
  shipping_address: Json;
  billing_address: Json;
  shipping_method: string;
  payment_method: string;
}) {
  try {
    const { data: orderId, error } = await supabase.rpc('create_order', {
      p_shipping_address: orderData.shipping_address,
      p_billing_address: orderData.billing_address,
      p_shipping_method: orderData.shipping_method,
      p_payment_method: orderData.payment_method,
    });

    if (error) throw error;

    return { orderId };
  } catch (error) {
    console.error('Error creating order:', error);
    throw error;
  }
}