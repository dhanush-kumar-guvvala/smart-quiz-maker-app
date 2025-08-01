-- Remove automatic quiz status update triggers and functions
DROP TRIGGER IF EXISTS trigger_update_quiz_active_status ON quizzes;
DROP FUNCTION IF EXISTS update_quiz_active_status();
DROP FUNCTION IF EXISTS update_all_quiz_statuses();
DROP FUNCTION IF EXISTS update_specific_quiz_active_status(bigint);