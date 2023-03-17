-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('phidel', 'phidel' , 'phidelisoluoch@gmail.com' , 'e0b69ea1-57e2-42ad-8025-dd372666785d');
  
INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'phidel' LIMIT 1),
    'This is my first crudd!',
    current_timestamp + interval '10 day'
  )