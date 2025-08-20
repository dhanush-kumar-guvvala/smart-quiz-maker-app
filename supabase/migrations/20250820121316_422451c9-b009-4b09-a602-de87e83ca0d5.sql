-- Add foreign key constraints with CASCADE delete to ensure data cleanup

-- Add foreign key constraint for questions table
ALTER TABLE public.questions 
ADD CONSTRAINT fk_questions_quiz_id 
FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id) ON DELETE CASCADE;

-- Add foreign key constraint for quiz_attempts table
ALTER TABLE public.quiz_attempts 
ADD CONSTRAINT fk_quiz_attempts_quiz_id 
FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id) ON DELETE CASCADE;

-- Add foreign key constraint for student_answers to quiz_attempts
ALTER TABLE public.student_answers 
ADD CONSTRAINT fk_student_answers_attempt_id 
FOREIGN KEY (attempt_id) REFERENCES public.quiz_attempts(id) ON DELETE CASCADE;

-- Add foreign key constraint for student_answers to questions
ALTER TABLE public.student_answers 
ADD CONSTRAINT fk_student_answers_question_id 
FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;

-- Add foreign key constraint for student_quiz_questions table
ALTER TABLE public.student_quiz_questions 
ADD CONSTRAINT fk_student_quiz_questions_quiz_id 
FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id) ON DELETE CASCADE;