import { User } from '@supabase/supabase-js';
import { motion } from 'framer-motion';
import { PasswordChange } from './security/PasswordChange';
import { SecurityOverview } from './security/SecurityOverview';
import { Shield } from 'lucide-react';

interface SecuritySettingsProps {
  user: User;
}

export function SecuritySettings({ user }: SecuritySettingsProps) {
  const containerVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        staggerChildren: 0.2
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 }
  };

  return (
    <motion.div
      className="space-y-6"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-900">Security Settings</h2>
        <div className="flex items-center space-x-2 text-sm text-gray-500">
          <Shield className="h-4 w-4" />
          <span>Security Status: Strong</span>
        </div>
      </div>

      <motion.div variants={itemVariants}>
        <SecurityOverview user={user} />
      </motion.div>

      <div className="grid md:grid-cols-2 gap-6">
        <motion.div variants={itemVariants}>
          <PasswordChange />
        </motion.div>
      </div>

      <motion.div 
        className="bg-yellow-50 rounded-lg p-4 text-sm text-yellow-700"
        variants={itemVariants}
      >
        <p className="flex items-center">
          <span className="font-medium">Security tip:</span>
          <span className="ml-2">
            Use a strong password that you don't use anywhere else,
            and never share it with anyone.
          </span>
        </p>
      </motion.div>
    </motion.div>
  );
}