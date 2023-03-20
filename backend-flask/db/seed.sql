-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('phidel', 'phidel' , 'phidelisoluoch@gmail.com' , 'e0b69ea1-57e2-42ad-8025-dd372666785d'),
  ('Sama', 'Sama' , 'oluoch.phidelist@students.kyu.ac.ke' , '1e5dc2a1-3c34-42e9-8ed4-b3b74b1e9b37');
  
INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'phidel' LIMIT 1),
    'This is my first crudd!',
    current_timestamp + interval '10 day'
  )