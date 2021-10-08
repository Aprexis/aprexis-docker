UPDATE diseases
  SET name = question_key
  WHERE name IS NULL OR TRIM(name) = '';
