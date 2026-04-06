-- Migration script to convert existing `workouts` to the new Session/Exercises schema

-- 1. Create the new workout_exercises table
CREATE TABLE IF NOT EXISTS public.workout_exercises (
  id BIGSERIAL PRIMARY KEY,
  workout_id BIGINT NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
  exercise_id BIGINT REFERENCES public.exercises(id) ON DELETE SET NULL,
  sets INT,
  reps INT,
  weight_kg NUMERIC(6,2),
  order_index INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Migrate existing data from workouts to workout_exercises
INSERT INTO public.workout_exercises (workout_id, exercise_id, sets, reps, weight_kg, created_at)
SELECT id, exercise_id, sets, reps, weight_kg, created_at
FROM public.workouts
WHERE exercise_id IS NOT NULL; 

-- 3. Update posture_analyses to point to the new workout_exercise
ALTER TABLE public.posture_analyses 
ADD COLUMN workout_exercise_id BIGINT REFERENCES public.workout_exercises(id) ON DELETE CASCADE;

-- Map existing posture_analyses to the newly created workout_exercises
UPDATE public.posture_analyses pa
SET workout_exercise_id = we.id
FROM public.workout_exercises we
WHERE pa.workout_id = we.workout_id;

-- Drop old constraints and columns from posture_analyses
ALTER TABLE public.posture_analyses DROP CONSTRAINT IF EXISTS uq_posture_one_per_workout;
ALTER TABLE public.posture_analyses DROP COLUMN IF EXISTS workout_id;

-- Fix the existing data if any rows in posture_analyses missed migration (unlikely, but ensures NOT NULL constraint passes)
DELETE FROM public.posture_analyses WHERE workout_exercise_id IS NULL;

-- Add new constraint and set NOT NULL
ALTER TABLE public.posture_analyses ADD CONSTRAINT uq_posture_one_per_workout_exercise UNIQUE (workout_exercise_id);
ALTER TABLE public.posture_analyses ALTER COLUMN workout_exercise_id SET NOT NULL;

-- 4. Clean up workouts table
ALTER TABLE public.workouts DROP COLUMN IF EXISTS exercise_id;
ALTER TABLE public.workouts DROP COLUMN IF EXISTS sets;
ALTER TABLE public.workouts DROP COLUMN IF EXISTS reps;
ALTER TABLE public.workouts DROP COLUMN IF EXISTS weight_kg;

-- 5. Add index
CREATE INDEX IF NOT EXISTS ix_workout_exercises_workout ON public.workout_exercises(workout_id);
