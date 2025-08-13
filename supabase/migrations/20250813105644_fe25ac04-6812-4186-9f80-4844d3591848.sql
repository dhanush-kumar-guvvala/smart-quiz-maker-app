-- Fix critical security vulnerabilities

-- 1. Fix the Security Definer View issue by replacing with proper RLS policies
DROP VIEW IF EXISTS public.student_quiz_questions;

-- 2. Create a secure function with proper search_path to prevent function hijacking
CREATE OR REPLACE FUNCTION public.can_student_see_correct_answers(question_quiz_id uuid)
RETURNS boolean 
LANGUAGE plpgsql 
SECURITY DEFINER 
STABLE
SET search_path = ''
AS $$
DECLARE
  student_attempt_completed boolean := false;
BEGIN
  -- Check if the current student has a completed attempt for this quiz
  SELECT EXISTS (
    SELECT 1 
    FROM public.quiz_attempts 
    WHERE quiz_id = question_quiz_id 
      AND student_id = auth.uid() 
      AND is_completed = true
  ) INTO student_attempt_completed;
  
  RETURN student_attempt_completed;
END;
$$;

-- 3. Update all other security definer functions to have proper search_path
CREATE OR REPLACE FUNCTION public.delete_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Delete the user's profile first (due to RLS, this will only delete the current user's profile)
  DELETE FROM public.profiles WHERE id = auth.uid();
  
  -- The auth.users deletion needs to be handled by Supabase Auth API
  -- This function will only clean up the profile data
END;
$$;

CREATE OR REPLACE FUNCTION public.generate_quiz_code()
RETURNS text
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.set_quiz_code()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF NEW.quiz_code IS NULL OR NEW.quiz_code = '' THEN
    NEW.quiz_code := public.generate_quiz_code();
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_quiz_attempts_username()
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    UPDATE public.quiz_attempts qa
    SET username = p.username
    FROM public.profiles p
    WHERE qa.student_id = p.id;
END;
$$;

CREATE OR REPLACE FUNCTION public.set_quiz_attempts_username()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    -- Fetch and set the username from profiles table
    SELECT username INTO NEW.username
    FROM public.profiles
    WHERE id = NEW.student_id;
    
    RETURN NEW;
END;
$$;

-- 4. Create a secure table for student quiz questions instead of a view
CREATE TABLE IF NOT EXISTS public.student_quiz_questions AS
SELECT 
  id,
  quiz_id,
  question_text,
  question_type,
  difficulty,
  options,
  points,
  order_index,
  created_at,
  -- Never expose correct answers in this table
  NULL::text as correct_answer
FROM public.questions
WHERE false; -- Make it empty initially

-- 5. Enable RLS on the student_quiz_questions table
ALTER TABLE public.student_quiz_questions ENABLE ROW LEVEL SECURITY;

-- 6. Create secure RLS policies for student_quiz_questions
CREATE POLICY "Students can view questions for active quizzes only" 
ON public.student_quiz_questions
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.quizzes 
    WHERE quizzes.id = student_quiz_questions.quiz_id 
      AND quizzes.is_active = true
  )
);

-- 7. Create policy for teachers to view questions in student view (for debugging)
CREATE POLICY "Teachers can view questions for their quizzes in student view" 
ON public.student_quiz_questions
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.quizzes 
    WHERE quizzes.id = student_quiz_questions.quiz_id 
      AND quizzes.teacher_id = auth.uid()
  )
);

-- 8. Create a function to populate student_quiz_questions safely
CREATE OR REPLACE FUNCTION public.populate_student_quiz_questions()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  -- Clear and repopulate the table with safe data (no correct answers)
  TRUNCATE public.student_quiz_questions;
  
  INSERT INTO public.student_quiz_questions (
    id, quiz_id, question_text, question_type, difficulty, 
    options, points, order_index, created_at, correct_answer
  )
  SELECT 
    id, quiz_id, question_text, question_type, difficulty,
    options, points, order_index, created_at,
    NULL::text as correct_answer -- Never expose correct answers
  FROM public.questions;
END;
$$;

-- 9. Populate the table initially
SELECT public.populate_student_quiz_questions();

-- 10. Create trigger to keep student_quiz_questions in sync (without correct answers)
CREATE OR REPLACE FUNCTION public.sync_student_quiz_questions()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.student_quiz_questions (
      id, quiz_id, question_text, question_type, difficulty,
      options, points, order_index, created_at, correct_answer
    ) VALUES (
      NEW.id, NEW.quiz_id, NEW.question_text, NEW.question_type, NEW.difficulty,
      NEW.options, NEW.points, NEW.order_index, NEW.created_at, NULL
    );
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE public.student_quiz_questions 
    SET 
      quiz_id = NEW.quiz_id,
      question_text = NEW.question_text,
      question_type = NEW.question_type,
      difficulty = NEW.difficulty,
      options = NEW.options,
      points = NEW.points,
      order_index = NEW.order_index,
      created_at = NEW.created_at,
      correct_answer = NULL -- Always NULL for security
    WHERE id = NEW.id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM public.student_quiz_questions WHERE id = OLD.id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

-- Create the trigger
DROP TRIGGER IF EXISTS sync_student_quiz_questions_trigger ON public.questions;
CREATE TRIGGER sync_student_quiz_questions_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.questions
  FOR EACH ROW EXECUTE FUNCTION public.sync_student_quiz_questions();

-- 11. Grant appropriate permissions
GRANT SELECT ON public.student_quiz_questions TO authenticated;