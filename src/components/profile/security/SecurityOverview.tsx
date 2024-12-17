import { User } from '@supabase/supabase-js';
import { motion } from 'framer-motion';
import { Shield, AlertTriangle, CheckCircle } from 'lucide-react';

interface SecurityOverviewProps {
  user: User;
}

export function SecurityOverview({ user }: SecurityOverviewProps) {
  const securityScore = calculateSecurityScore(user);

  return (
    <div className="bg-white rounded-lg p-6 shadow-sm mb-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-2">
          <Shield className="h-5 w-5 text-brand-primary" />
          <h3 className="text-lg font-medium text-gray-900">Security Overview</h3>
        </div>
        <div className="flex items-center space-x-2">
          <span className="text-sm font-medium text-gray-700">Security Score:</span>
          <div className="flex items-center space-x-1">
            {[...Array(MAX_SECURITY_SCORE)].map((_, i) => (
              <motion.div
                key={i}
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: i * 0.1 }}
                className={`w-2 h-8 rounded-full ${
                  i < securityScore
                    ? 'bg-green-500'
                    : 'bg-gray-200'
                }`}
              />
            ))}
          </div>
        </div>
      </div>

      <div className="space-y-4">
        <SecurityItem
          title="Email Verification"
          status={user.email_confirmed_at ? 'complete' : 'warning'}
          message={user.email_confirmed_at 
            ? 'Your email is verified'
            : 'Please verify your email'
          }
        />
        <SecurityItem
          title="Password Strength"
          status="info"
          message="Use a strong, unique password"
        />
      </div>
    </div>
  );
}

interface SecurityItemProps {
  title: string;
  status: 'complete' | 'warning' | 'info';
  message: string;
}

function SecurityItem({ title, status, message }: SecurityItemProps) {
  const statusColors = {
    complete: 'text-green-700 bg-green-50',
    warning: 'text-yellow-700 bg-yellow-50',
    info: 'text-blue-700 bg-blue-50'
  };

  const StatusIcon = {
    complete: CheckCircle,
    warning: AlertTriangle,
    info: Shield
  }[status];

  return (
    <div className={`flex items-center justify-between p-4 rounded-lg ${statusColors[status]}`}>
      <div className="flex items-center space-x-3">
        <StatusIcon className="h-5 w-5" />
        <div>
          <h4 className="font-medium">{title}</h4>
          <p className="text-sm opacity-90">{message}</p>
        </div>
      </div>
    </div>
  );
}

const MAX_SECURITY_SCORE = 4;

function calculateSecurityScore(user: User): number {
  let score = 1; // Base score

  if (user.email_confirmed_at) score++;
  if (user.phone) score++;
  if (user.updated_at && isRecentlyUpdated(user.updated_at)) score++;

  return score;
}

function isRecentlyUpdated(date: string): boolean {
  const threeMonthsAgo = new Date();
  threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
  return new Date(date) > threeMonthsAgo;
}