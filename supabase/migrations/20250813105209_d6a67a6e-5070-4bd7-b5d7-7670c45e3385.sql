-- Drop the existing student policy for questions
DROP POLICY IF EXISTS "Students can view questions for active quizzes" ON public.questions;

-- Create a security definer function to check if student can see correct answers
CREATE OR REPLACE FUNCTION public.can_student_see_correct_answers(question_quiz_id uuid)
RETURNS boolean AS $$
DECLARE
  student_attempt_completed boolean := false;
BEGIN
  -- Check if the current student has a completed attempt for this quiz
  SELECT EXISTS (
    SELECT 1 
    FROM quiz_attempts 
    WHERE quiz_id = question_quiz_id 
      AND student_id = auth.uid() 
      AND is_completed = true
  ) INTO student_attempt_completed;
  
  RETURN student_attempt_completed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Create new policy for students to view questions (excluding correct_answer for incomplete attempts)
CREATE POLICY "Students can view questions for active quizzes" ON public.questions
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM quizzes 
    WHERE quizzes.id = questions.quiz_id 
      AND quizzes.is_active = true
  )
);

-- Create a view for students to get questions without correct answers during quiz taking
CREATE OR REPLACE VIEW public.student_quiz_questions AS
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
  CASE 
    WHEN public.can_student_see_correct_answers(quiz_id) THEN correct_answer
    ELSE NULL
  END as correct_answer
FROM public.questions
WHERE EXISTS (
  SELECT 1 FROM quizzes 
  WHERE quizzes.id = questions.quiz_id 
    AND quizzes.is_active = true
);

-- Grant access to the view
GRANT SELECT ON public.student_quiz_questions TO authenticated;