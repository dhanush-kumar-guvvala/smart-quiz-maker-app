-- Add timezone field to profiles table
ALTER TABLE public.profiles 
ADD COLUMN timezone TEXT DEFAULT 'Asia/Kolkata';

-- Update existing profiles to have default timezone
UPDATE public.profiles 
SET timezone = 'Asia/Kolkata' 
WHERE timezone IS NULL;