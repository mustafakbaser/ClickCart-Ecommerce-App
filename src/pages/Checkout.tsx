import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCartStore } from '../store/useCartStore';
import { CheckoutSteps } from '../components/checkout/CheckoutSteps';
import { ShippingForm } from '../components/checkout/ShippingForm';
import { PaymentForm } from '../components/checkout/PaymentForm';
import { OrderReview } from '../components/checkout/OrderReview';
import { CheckoutFormData } from '../types/checkout';
import { createOrder } from '../services/checkoutService';
import { formatCurrency } from '../lib/utils';

const initialFormData: CheckoutFormData = {
  shippingAddress: {
    fullName: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    state: '',
    postalCode: '',
    country: ''
  },
  billingAddress: {
    sameAsShipping: true,
    fullName: '',
    email: '',
    phone: '',
    address: '',
    city: '',
    state: '',
    postalCode: '',
    country: ''
  },
  shippingMethod: 'standard',
  paymentMethod: '',
  saveInfo: false
};

export function Checkout() {
  const navigate = useNavigate();
  const { items, total, clearCart } = useCartStore();
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState<CheckoutFormData>(initialFormData);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (items.length === 0) {
    navigate('/cart');
    return null;
  }

  const handleStepComplete = (step: number, data: Partial<CheckoutFormData>) => {
    setFormData(prev => ({ ...prev, ...data }));
    setCurrentStep(step + 1);
  };

  const handlePlaceOrder = async () => {
    setLoading(true);
    setError(null);

    try {
      const result = await createOrder(formData);
      
      if ('error' in result) {
        setError(result.error);
        return;
      }

      clearCart();
      navigate(`/order-confirmation/${result.orderId}`);
    } catch (err) {
      setError('An error occurred while placing your order. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      <CheckoutSteps currentStep={currentStep} />

      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg text-red-600">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          {currentStep === 1 && (
            <ShippingForm
              initialData={formData}
              onComplete={(data) => handleStepComplete(1, data)}
            />
          )}

          {currentStep === 2 && (
            <PaymentForm
              initialData={formData}
              onComplete={(data) => handleStepComplete(2, data)}
              onBack={() => setCurrentStep(1)}
            />
          )}

          {currentStep === 3 && (
            <OrderReview
              formData={formData}
              items={items}
              loading={loading}
              onBack={() => setCurrentStep(2)}
              onPlaceOrder={handlePlaceOrder}
            />
          )}
        </div>

        <div className="lg:col-span-1">
          <div className="bg-white rounded-lg shadow-sm p-6 sticky top-24">
            <h2 className="text-lg font-semibold mb-4">Order Summary</h2>
            <div className="space-y-4">
              {items.map((item) => (
                <div key={item.id} className="flex items-center space-x-4">
                  <img
                    src={item.image_url}
                    alt={item.title}
                    className="w-16 h-16 object-cover rounded"
                  />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {item.title}
                    </p>
                    <p className="text-sm text-gray-500">
                      Quantity: {item.quantity}
                    </p>
                  </div>
                  <span className="text-sm font-medium text-gray-900">
                    {formatCurrency(item.price * item.quantity)}
                  </span>
                </div>
              ))}

              <div className="border-t pt-4 space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Subtotal</span>
                  <span className="font-medium">{formatCurrency(total)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Shipping</span>
                  <span className="font-medium">Calculated at next step</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-600">Tax</span>
                  <span className="font-medium">Calculated at next step</span>
                </div>
                <div className="flex justify-between text-lg font-bold border-t pt-2">
                  <span>Total</span>
                  <span>{formatCurrency(total)}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}