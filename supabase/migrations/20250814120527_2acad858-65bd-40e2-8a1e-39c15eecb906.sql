-- Add INSERT policy for student_quiz_questions to allow trigger synchronization
CREATE POLICY "Allow sync trigger to insert student quiz questions" 
ON public.student_quiz_questions 
FOR INSERT 
WITH CHECK (true);

-- Also add UPDATE and DELETE policies for the sync trigger to work properly
CREATE POLICY "Allow sync trigger to update student quiz questions" 
ON public.student_quiz_questions 
FOR UPDATE 
USING (true);

CREATE POLICY "Allow sync trigger to delete student quiz questions" 
ON public.student_quiz_questions 
FOR DELETE 
USING (true);