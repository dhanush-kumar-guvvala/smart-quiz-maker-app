-- Add username column to quiz_attempts table
ALTER TABLE quiz_attempts ADD COLUMN username TEXT;

-- Update existing records with usernames from profiles table
UPDATE quiz_attempts 
SET username = profiles.username 
FROM profiles 
WHERE quiz_attempts.student_id = profiles.id;

-- Create function to automatically set username when inserting/updating quiz_attempts
CREATE OR REPLACE FUNCTION set_quiz_attempts_username()
RETURNS TRIGGER AS $$
BEGIN
    -- Fetch and set the username from profiles table
    SELECT username INTO NEW.username
    FROM profiles
    WHERE id = NEW.student_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically set username on insert/update
CREATE TRIGGER trigger_set_quiz_attempts_username
    BEFORE INSERT OR UPDATE ON quiz_attempts
    FOR EACH ROW
    EXECUTE FUNCTION set_quiz_attempts_username();