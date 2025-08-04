-- Create function to delete user account
CREATE OR REPLACE FUNCTION delete_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Delete the user's profile first (due to RLS, this will only delete the current user's profile)
  DELETE FROM public.profiles WHERE id = auth.uid();
  
  -- The auth.users deletion needs to be handled by Supabase Auth API
  -- This function will only clean up the profile data
END;
$$;