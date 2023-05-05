--Edlyn Garcia Final Project




--LOG INTO sudo -u postgres psql
--CREATE DATABASE ub_database;
--\c ub_database
--CREATE ROLE ub_database WITH LOGIN PASSWORD '6745';
--log out and log in back with user
--psql --host=localhost --dbname=ub_database --username ub_database


DROP TABLE IF EXISTS programs CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS student_programs CASCADE;
DROP TABLE IF EXISTS feeder CASCADE;
DROP TABLE IF EXISTS student_information CASCADE;
DROP TABLE IF EXISTS semester_grades CASCADE;


CREATE TABLE programs(               
  program_id INT PRIMARY KEY,
  program_code VARCHAR(50),
  program_name TEXT NOT NULL,
  program_degree TEXT NOT NULL
 
);

CREATE TABLE courses(               
course_id INT PRIMARY KEY,
course_code CHAR(50) NOT NULL,
course_title TEXT NOT NULL,
course_credits INT 
);

CREATE TABLE feeder(               
  feeder_id INT PRIMARY KEY,
  school_name VARCHAR(100)
);

CREATE TABLE student_information(
student_id INT PRIMARY KEY,
DOB text NOT NULL,
gender CHAR(1) NOT NULL,
district TEXT ,
city TEXT,
ethnicity TEXT NOT NULL,
feeder_id INT,
 FOREIGN KEY (feeder_id)
  REFERENCES feeder(feeder_id)
);

CREATE TABLE student_programs(
  s_pro_id INT PRIMARY KEY,
  student_id INT NOT NULL,
  program_id INT NOT NULL, 
 program_start DATE NOT NULL,
 program_end DATE,
 program_status VARCHAR(100) NOT NULL,
 grad_date DATE,
FOREIGN KEY (student_id)
 REFERENCES student_information(student_id),
 FOREIGN KEY (program_id)
 REFERENCES programs(program_id)
);

CREATE TABLE semester_grades (
    semester_grades_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    semester VARCHAR(10),
    semester_attempted DECIMAL,
    semester_credit_earned DECIMAL,
    semester_points DECIMAL,
    semester_gpa DECIMAL,
    course_id INT NOT NULL,
    course_grade VARCHAR(2),
    course_points DECIMAL,
    course_gpa DECIMAL,
    comments TEXT,
    cgpa DECIMAL,
   FOREIGN KEY (course_id)
   REFERENCES courses(course_id),
   FOREIGN KEY (student_id)
   REFERENCES student_information(student_id)
);





\COPY programs       --works
FROM '/home/edlyn/Downloads/cvs/programs.csv' 
DELIMITER ','
CSV HEADER;

\COPY courses  --works     
FROM '/home/edlyn/Downloads/cvs/courses.csv' 
DELIMITER ','
CSV HEADER;

\COPY student_programs   --works
FROM '/home/edlyn/Downloads/cvs/student_programs.csv' 
DELIMITER ','
CSV HEADER;

\COPY feeder          --works                      
FROM '/home/edlyn/Downloads/cvs/feeder.csv'  
DELIMITER ','
CSV HEADER;


\COPY student_information --works
FROM '/home/edlyn/Downloads/cvs/student_information.csv'          
DELIMITER ','
CSV HEADER;

\COPY semester_grades  --works    
FROM '/home/edlyn/Downloads/cvs/semester_grades.csv' 
DELIMITER ','
CSV HEADER;

 
--Quieries for Final project database

--Demographic questions 1-5:
--1. Find the total number of students and average course points by feeder institutions. --works
SELECT COUNT(s.student_id) as student_id_count, AVG(sg.course_points) as avg_course_points, f.feeder_id, f.school_name
FROM student_information AS s
INNER JOIN feeder AS f 
ON f.feeder_id = s.feeder_id
INNER JOIN semester_grades AS sg 
ON sg.student_id = sg.student_id
GROUP BY f.feeder_id, f.school_name
ORDER BY avg_course_points DESC;


--2. Find the total number of students and average course points by gender.--works
SELECT COUNT(DISTINCT s.student_id) as student_id_count, AVG(sg.course_points) as avg_course_points, s.gender
FROM student_information AS s
INNER JOIN semester_grades AS sg
ON sg.student_id=sg.student_id
GROUP BY s.gender
ORDER BY avg_course_points DESC; 

--3. Find the total number of students and average course points by ethnicity.--works
SELECT COUNT(s.student_id) as student_id_count, AVG(sg.course_points) as avg_course_points, s.ethnicity
FROM student_information AS s
INNER JOIN semester_grades AS sg
ON sg.student_id = sg.student_id
GROUP BY s.ethnicity
ORDER BY avg_course_points DESC;

--4. Find the total number of students and average course points by city.--works
SELECT  COUNT(DISTINCT s.student_id) as student_id_count,AVG(sg.course_points) as avg_course_points,s.city
FROM student_information AS s
INNER JOIN semester_grades AS sg
ON sg.student_id=sg.student_id
GROUP BY s.city
ORDER BY avg_course_points DESC; 

--5. Find the total number of students and average course points by district. --works
SELECT COUNT(*) as student_id_count, AVG(sg.course_points) as avg_course_points, s.district
FROM student_information AS s
INNER JOIN semester_grades AS sg
ON sg.student_id=sg.student_id
GROUP BY s.district
ORDER BY avg_course_points DESC;

--6. Overall Acceptance/admission rates in the BINT program, ranked by feeder instituition admission rates and grades. --works
SELECT 
    f.school_name, 
    COUNT(DISTINCT s.student_id) * 100 / COUNT(*) as admission_rate, 
    AVG(sg.cgpa) as course_gpa_average
FROM 
    student_information as s
    INNER JOIN student_programs as sp
     ON s.student_id = sp.student_id
    INNER JOIN programs as p 
    ON sp.program_id = p.program_id
    INNER JOIN semester_grades as sg 
    ON sg.student_id = s.student_id
    INNER JOIN feeder as f 
    ON f.feeder_id = s.feeder_id
WHERE 
    p.program_code = 'BINT'
GROUP BY 
    f.school_name
ORDER BY 
    admission_rate DESC, 
    course_gpa_average DESC;

--7.Calculate graduation rate for student's in BINT program. --works
SELECT COUNT(DISTINCT s.student_id)*100/(
    SELECT COUNT(DISTINCT student_id) 
    FROM student_programs 
    WHERE program_id IN (
        SELECT program_id 
        FROM programs 
        WHERE program_code = 'BINT'
    )
) as graduation_rate 
FROM student_programs as s 
WHERE program_id IN (
    SELECT program_id 
    FROM programs 
    WHERE program_code = 'BINT'
) AND s.program_status = 'Graduated';



--8.Calculate Average amount of time it takes BINT student to graduate.--works
SELECT AVG((sp.program_end) - (sp.program_start))/365 as avg_graduation_time_in_years
FROM student_information as s
INNER JOIN student_programs as sp
ON s.student_id = sp.student_id
INNER JOIN programs as p
ON sp.program_id = p.program_id
WHERE p.program_code = 'BINT';

--9.Find the percentage of students who passed Math courses in the BINT program --works
 SELECT
  COUNT(DISTINCT sg.student_id) * 100.0 / (
    SELECT COUNT(DISTINCT sp.student_id)
    FROM student_programs  as sp
    INNER JOIN programs as p 
    ON sp.program_id = p.program_id
    WHERE p.program_code = 'BINT'
  ) as pass_rate
FROM semester_grades as sg
INNER JOIN courses as c 
ON sg.course_id = c.course_id
INNER JOIN student_information as s 
ON sg.student_id = s.student_id
INNER JOIN student_programs as sp 
ON sg.student_id = sp.student_id AND sp.program_id = (
  SELECT program_id 
  FROM programs 
  WHERE program_code = 'BINT'
)
WHERE c.course_code LIKE 'MATH%' 
  AND sg.cgpa >= '2.0';
--10.Find the perentage of students who passed IT courses in the BINT program --works
SELECT
  COUNT(DISTINCT sg.student_id) * 100.0 / (
    SELECT COUNT(DISTINCT sp.student_id)
    FROM student_programs as sp
    INNER JOIN programs as p 
    ON sp.program_id = p.program_id
    WHERE p.program_code = 'BINT'
  ) as pass_rate
FROM semester_grades  as sg
INNER JOIN courses as c 
ON sg.course_id = c.course_id
INNER JOIN student_information as s 
ON sg.student_id = s.student_id
INNER JOIN student_programs as sp 
ON sg.student_id = sp.student_id AND sp.program_id = (
  SELECT program_id 
  FROM programs 
  WHERE program_code = 'BINT'
)
WHERE c.course_code LIKE 'CMPS%' 
  AND sg.cgpa >= '2.0';
--11.Find the percentage of students who failed Math courses in the BINT program --works
    SELECT
  COUNT(DISTINCT sg.student_id) * 100.0 / (
    SELECT COUNT(DISTINCT sp.student_id)
    FROM student_programs as sp
    INNER JOIN programs as p 
    ON sp.program_id = p.program_id
    WHERE p.program_code = 'BINT'
  ) as fail_rate
FROM semester_grades as sg
INNER JOIN courses as c 
ON sg.course_id = c.course_id
INNER JOIN student_information as s 
ON sg.student_id = s.student_id
INNER JOIN student_programs as sp 
ON sg.student_id = sp.student_id AND sp.program_id = (
  SELECT program_id 
  FROM programs 
  WHERE program_code = 'BINT'
)
WHERE c.course_code LIKE 'MATH%' 
  AND sg.cgpa <= '2.0';
--12.Find the percentage of students who failed IT courses in the BINT program --works
  SELECT
  COUNT(DISTINCT sg.student_id) * 100.0 / (
    SELECT COUNT(DISTINCT sp.student_id)
    FROM student_programs as sp
    INNER JOIN programs as p 
    ON sp.program_id = p.program_id
    WHERE p.program_code = 'BINT'
  ) as fail_rate
FROM semester_grades as sg
INNER JOIN courses as c 
ON sg.course_id = c.course_id
INNER JOIN student_information as s 
ON sg.student_id = s.student_id
INNER JOIN student_programs as sp 
ON sg.student_id = sp.student_id AND sp.program_id = (
  SELECT program_id 
  FROM programs 
  WHERE program_code = 'BINT'
)
WHERE c.course_code LIKE 'CMPS%' 
  AND sg.cgpa <= '2.0';

--13. Average gpa per course --works
SELECT AVG(sg.cgpa) as avg__course_gpa,c. course_title
FROM semester_grades as sg
INNER JOIN courses as c 
ON c.course_id=sg.course_id
GROUP BY c.course_title
ORDER BY avg__course_gpa DESC;

  --Queries based on project 2 Database that will assist in analyzing and creating the rentention strategy.

--Demographic questions 1-5:

--1. Find the total number of students and average course points by feeder institutions. --works
SELECT COUNT(s.student_id) as student_id_count, AVG(g.course_points) as avg_course_points, f.feeder_id, f.school_name
FROM student_information AS s
INNER JOIN feeder AS f 
ON f.feeder_id = s.feeder_id
INNER JOIN grades AS g 
ON s.student_id = g.student_id
GROUP BY f.feeder_id, f.school_name
ORDER BY avg_course_points DESC;


--2. Find the total number of students and average course points by gender.--works
SELECT COUNT(DISTINCT s.student_id) as student_id_count, AVG(g.course_points) as avg_course_points, s.gender
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.gender
ORDER BY avg_course_points DESC; 

--3. Find the total number of students and average course points by ethnicity.--works
SELECT COUNT(s.student_id) as student_id_count, AVG(g.course_points) as avg_course_points, s.ethnicity
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id = g.student_id
GROUP BY s.ethnicity
ORDER BY avg_course_points DESC;

--4. Find the total number of students and average course points by city.--works
SELECT  COUNT(DISTINCT s.student_id) as student_id_count,AVG(g.course_points) as avg_course_points,s.city
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.city
ORDER BY avg_course_points DESC; 

--5. Find the total number of students and average course points by district.--works
SELECT COUNT(*) as student_id_count, AVG(g.course_points) as avg_course_points, s.district
FROM student_information AS s
INNER JOIN grades AS g
ON s.student_id=g.student_id
GROUP BY s.district
ORDER BY avg_course_points DESC;

--6. Overall Acceptance/admission rates in the AINT program, ranked by feeder instituition admission rates and grades. --works
SELECT 
  f.school_name, 
  COUNT(DISTINCT s.student_id) * 100.0 / COUNT(*) as admission_rate,
  AVG(g.course_points) as avg_course_points
FROM 
  student_information as s
  INNER JOIN feeder as f 
  ON s.feeder_id = f.feeder_id
  INNER JOIN grades as g 
  ON s.student_id = g.student_id
  INNER JOIN courses_programs as cp 
  ON cp.course_id = g.course_id
  INNER JOIN programs as p 
  ON p.program_id = cp.program_id
WHERE 
  p.program_code = 'AINT'
GROUP BY 
  f.school_name
ORDER BY 
  admission_rate DESC, 
  avg_course_points DESC;
--7.Calculate graduation rate for student's in AINT program. --works
SELECT 
  COUNT(CASE WHEN s.program_status = 'Graduated' THEN 1 END) * 100.0 / COUNT(*) AS graduation_rate
FROM 
    student_information as s
  INNER JOIN feeder as f 
  ON s.feeder_id = f.feeder_id
  INNER JOIN grades as g 
  ON s.student_id = g.student_id
  INNER JOIN courses_programs as cp 
  ON cp.course_id = g.course_id
  INNER JOIN programs as p 
  ON p.program_id = cp.program_id
WHERE 
  p.program_code = 'AINT';


--8.Calculate Average amount of time it takes AINT student to graduate. --Works 
SELECT AVG((programend) - (program_start))/365 as avg_graduation_time_in_years
FROM 
    student_information as s
  INNER JOIN feeder as f 
  ON s.feeder_id = f.feeder_id
  INNER JOIN grades as g 
  ON s.student_id = g.student_id
  INNER JOIN courses_programs as cp 
  ON cp.course_id = g.course_id
  INNER JOIN programs as p 
  ON p.program_id = cp.program_id
WHERE 
  p.program_code = 'AINT';




--9.Find the percentage of students who passed Math courses in the AINT program --works
SELECT 
COUNT(CASE WHEN c.course_code LIKE 'MATH%' AND g.course_points >= 6 THEN 1 END)* 100.0 / COUNT(CASE WHEN p.program_code = 'AINT' THEN 1 END) AS pass_rate
FROM student_information s
INNER JOIN feeder f 
ON s.feeder_id = f.feeder_id
INNER JOIN grades g 
ON s.student_id = g.student_id
INNER JOIN courses_programs cp 
ON cp.course_id = g.course_id
INNER JOIN programs p 
ON p.program_id = cp.program_id
INNER JOIN courses c 
ON c.course_id = cp.course_id
WHERE p.program_code = 'AINT';


--10.Find the percentage of students who passed IT courses in the AINT program --works
SELECT 
COUNT(CASE WHEN c.course_code LIKE 'CMPS%' AND g.course_points >= 6 THEN 1 END)* 100.0 / COUNT(CASE WHEN p.program_code = 'AINT' THEN 1 END) AS pass_rate
FROM student_information s
INNER JOIN feeder f 
ON s.feeder_id = f.feeder_id
INNER JOIN grades g 
ON s.student_id = g.student_id
INNER JOIN courses_programs cp 
ON cp.course_id = g.course_id
INNER JOIN programs p 
ON p.program_id = cp.program_id
INNER JOIN courses c 
ON c.course_id = cp.course_id
WHERE p.program_code = 'AINT';


--11.Find the percentage of students who failed Math courses in the AINT program --works
SELECT 
COUNT(CASE WHEN c.course_code LIKE 'MATH%' AND g.course_points < 7.5 THEN 1 END)* 100.0 / COUNT(CASE WHEN p.program_code = 'AINT' THEN 1 END) AS fail_rate
FROM student_information s
INNER JOIN feeder f 
ON s.feeder_id = f.feeder_id
INNER JOIN grades g 
ON s.student_id = g.student_id
INNER JOIN courses_programs cp 
ON cp.course_id = g.course_id
INNER JOIN programs p 
ON p.program_id = cp.program_id
INNER JOIN courses c 
ON c.course_id = cp.course_id
WHERE p.program_code = 'AINT';
--12.Find the percentage of students who failed IT courses in the AINT program --works
SELECT 
COUNT(CASE WHEN c.course_code LIKE 'CMPS%' AND g.course_points <7.5 THEN 1 END)* 100.0 / COUNT(CASE WHEN p.program_code = 'AINT' THEN 1 END) AS fail_rate
FROM student_information s
INNER JOIN feeder f 
ON s.feeder_id = f.feeder_id
INNER JOIN grades g 
ON s.student_id = g.student_id
INNER JOIN courses_programs cp 
ON cp.course_id = g.course_id
INNER JOIN programs p 
ON p.program_id = cp.program_id
INNER JOIN courses c 
ON c.course_id = cp.course_id
WHERE p.program_code = 'AINT';

--13. Average course points per course --works 
SELECT c.course_title,AVG(g.course_points) as avg_grade
FROM grades as g
INNER JOIN courses as c 
ON g.course_id = c.course_id
GROUP BY c.course_title;