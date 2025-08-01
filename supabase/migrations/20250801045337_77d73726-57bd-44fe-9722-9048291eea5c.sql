-- Remove automatic quiz status update triggers and functions (with CASCADE)
DROP TRIGGER IF EXISTS trigger_update_quiz_active_status ON quizzes CASCADE;
DROP TRIGGER IF EXISTS set_quiz_active_status ON quizzes CASCADE;
DROP FUNCTION IF EXISTS update_quiz_active_status() CASCADE;
DROP FUNCTION IF EXISTS update_all_quiz_statuses() CASCADE;
DROP FUNCTION IF EXISTS update_specific_quiz_active_status(bigint) CASCADE;