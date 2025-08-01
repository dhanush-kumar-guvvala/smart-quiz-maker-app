-- Make quiz_code nullable so the trigger can set it
ALTER TABLE quizzes ALTER COLUMN quiz_code DROP NOT NULL;