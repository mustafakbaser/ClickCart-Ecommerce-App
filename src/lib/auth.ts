import { AuthError, User } from '@supabase/supabase-js';
import { supabase } from './supabase';

export interface AuthResponse {
  user: User | null;
  error: AuthError | null;
}

export async function signUp(email: string, password: string, fullName: string): Promise<AuthResponse> {
  try {
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: fullName },
      },
    });

    if (authError) {
      console.error('Auth error:', authError);
      return { user: null, error: authError };
    }

    if (!authData.user) {
      return { user: null, error: new Error('No user data returned') as AuthError };
    }

    // The profile row is created by the create_profile_for_new_user database
    // trigger. With email confirmation on there is no session yet, so the user
    // is not signed in until they confirm and log in.
    return {
      user: authData.session ? authData.user : null,
      error: null,
      message: 'Please check your email for confirmation link'
    };
  } catch (error) {
    console.error('Signup error:', error);
    return { 
      user: null, 
      error: new Error('An unexpected error occurred during signup') as AuthError 
    };
  }
}

export async function signIn(email: string, password: string): Promise<AuthResponse> {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      if (error.message.includes('Email not confirmed')) {
        return { 
          user: null, 
          error: new Error('Please check your email and confirm your account') as AuthError 
        };
      }
      return { user: null, error };
    }

    if (!data.user) {
      return { user: null, error: new Error('No user data returned') as AuthError };
    }

    const { data: profileData } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', data.user.id)
      .single();

    if (profileData) {
      data.user.user_metadata = {
        ...data.user.user_metadata,
        ...profileData,
      };
    }

    return { user: data.user, error: null };
  } catch (error) {
    console.error('Sign in error:', error);
    return { 
      user: null, 
      error: new Error('An unexpected error occurred during sign in') as AuthError 
    };
  }
}

export async function signOut(): Promise<void> {
  const { error } = await supabase.auth.signOut();
  if (error) {
    console.error('Sign out error:', error);
    throw error;
  }
}

export async function getCurrentUser(): Promise<User | null> {
  try {
    const { data: { session } } = await supabase.auth.getSession();
    
    if (!session) {
      return null;
    }

    const { data: { user } } = await supabase.auth.getUser();
    
    if (!user) {
      return null;
    }

    const { data: profileData } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single();

    if (profileData) {
      user.user_metadata = {
        ...user.user_metadata,
        ...profileData,
      };
    }
    
    return user;
  } catch (error) {
    console.error('Get current user error:', error);
    return null;
  }
}

export async function updateProfile(userId: string, updates: { full_name?: string }): Promise<AuthError | null> {
  try {
    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId);

    if (profileError) {
      throw profileError;
    }

    const { error: updateError } = await supabase.auth.updateUser({
      data: updates
    });

    if (updateError) {
      throw updateError;
    }
    
    return null;
  } catch (error) {
    console.error('Update profile error:', error);
    return error as AuthError;
  }
}