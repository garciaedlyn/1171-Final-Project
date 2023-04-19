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
 program_start VARCHAR(100) NOT NULL,
 program_end VARCHAR(100),
 program_status VARCHAR(100) NOT NULL,
 grad_date VARCHAR(100),
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

 
 
  
