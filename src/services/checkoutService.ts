import { CartItem } from '../types';
import { CheckoutFormData, OrderSummary } from '../types/checkout';
import * as orderService from './orderService';

// Items, prices and the total are taken from the database cart by
// create_order(); the cart is cleared there too.
export async function createOrder(
  formData: CheckoutFormData
): Promise<{ orderId: string } | { error: string }> {
  try {
    const result = await orderService.createOrder({
      shipping_address: formData.shippingAddress,
      billing_address: formData.billingAddress.sameAsShipping 
        ? formData.shippingAddress 
        : formData.billingAddress,
      shipping_method: formData.shippingMethod,
      payment_method: formData.paymentMethod
    });

    return { orderId: result.orderId };
  } catch (error) {
    console.error('Error creating order:', error);
    return { error: 'Failed to create order' };
  }
}

export function calculateOrderSummary(
  items: CartItem[],
  shippingMethodId: string
): OrderSummary {
  const subtotal = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const shipping = getShippingCost(shippingMethodId);
  const tax = subtotal * 0.18; // 18% KDV

  return {
    subtotal,
    shipping,
    tax,
    total: subtotal + shipping + tax
  };
}

// Display only: create_order() in the database has the same prices and is
// what actually gets charged. Keep both in sync.
export function getShippingMethods() {
  return [
    {
      id: 'standard',
      name: 'Standard Shipping',
      description: 'Delivery in 4-5 business days',
      price: 9.99,
      estimatedDays: '4-5'
    },
    {
      id: 'express',
      name: 'Express Shipping',
      description: 'Delivery in 1-2 business days',
      price: 19.99,
      estimatedDays: '1-2'
    },
    {
      id: 'free',
      name: 'Free Shipping',
      description: 'Delivery in 5-7 business days',
      price: 0,
      estimatedDays: '5-7'
    }
  ];
}

function getShippingCost(methodId: string): number {
  const method = getShippingMethods().find(m => m.id === methodId);
  return method?.price ?? 0;
}