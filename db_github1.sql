--find number of students
select count(s.student_epita_email) from students s 



--get students population in each year
select * from students s 
select s.student_population_year_ref , count(s.student_epita_email) from students s group by s.student_population_year_ref 

--get students population in each program
select s.student_population_code_ref as "program",count(s.student_epita_email) as "Number_of_Students"
from students s group by s.student_population_code_ref order by count(s.student_epita_email)

--calculate age from dob

select c.contact_first_name || ' ' || c.contact_last_name as "full_name", (2021 - extract (year from c.contact_birthdate)) as age
from contacts c order by age 

--add age column to contacts

alter table contacts drop column contact_age

--delete column 

alter table contacts add column contact_age integer

--calculate age from dob and insert in col contact_age

update contacts set contact_age = (2021-extract(year from contact_birthdate))

select * from contacts c 

--avg student age

select c.contact_age
from contacts c 

select avg(c.contact_age)
from contacts c

--avg session duration for a course

select avg(c.duration)
from courses c 

--find the student with their present status


select a.attendance_presence from attendance a 

select c.contact_first_name || ' ' || c.contact_last_name as "name", s.student_epita_email as email, count(a.attendance_presence) as presence
from attendance a left join students s on a.attendance_student_ref = s.student_epita_email 
left join contacts c on s.student_contact_ref = c.contact_email where a.attendance_presence = 1
group by s.student_epita_email, c.contact_first_name , c.contact_last_name, a.attendance_presence 
order by name


--find the student with maximum abscent

select a.attendance_presence from attendance a 

with abscent_table as (
select c.contact_first_name || ' ' || c.contact_last_name as "name", s.student_epita_email as email, 
count(a.attendance_presence) as abscent
from attendance a left join students s on a.attendance_student_ref = s.student_epita_email 
left join contacts c on s.student_contact_ref = c.contact_email where a.attendance_presence = 0
group by s.student_epita_email, c.contact_first_name , c.contact_last_name, a.attendance_presence 
order by abscent desc 
)

select abtb.email, abtb.name, abtb.abscent from abscent_table abtb where 
abtb.abscent = (select max(abscent) from abscent_table )

--find number of abscent per student

select distinct s.student_epita_email , count(a.attendance_presence) as abscent
from students s left join attendance a on s.student_epita_email = a.attendance_student_ref 
where a.attendance_presence = 0
group by s.student_epita_email 
order by abscent desc

--find the course with most absents


with course_abscent as (
select c.course_name as name , count(a.attendance_presence) as abscent
from courses c left join attendance a on c.course_code = a.attendance_course_ref 
where a.attendance_presence = 0
group by c.course_name, a.attendance_presence order by abscent desc
)

select corab.name, corab.abscent
from course_abscent corab
where corab.abscent = (select max(abscent) from course_abscent)
                       
--find students who are not graded


select s.student_epita_email, g.grade_score 
from students s left join grades g on s.student_epita_email = g.grade_student_epita_email_ref 
where g.grade_score is null 


--find the teachers who are not in any session

select t.teacher_epita_email 
from teachers t left join sessions s on t.teacher_epita_email = s.session_prof_ref
where s.session_prof_ref is null 


--list of teacher who attend the total session 
select distinct t.teacher_epita_email, count(t.teacher_epita_email) as Total_Session
from teachers t right join sessions s on t.teacher_epita_email = s.session_prof_ref
group by t.teacher_epita_email order by Total_Session desc



-- find the DSA students details with grades 

select * 
from programs

select distinct c.contact_email as email, c.contact_first_name  || ' ' || c.contact_last_name as full_name, 
c.contact_address as address, c.contact_city as city, c.contact_country as country, c.contact_birthdate as birthdate,
c.contact_age as age, g.grade_score

from contacts c inner join students s on c.contact_email = s.student_contact_ref 
inner join grades g on s.student_epita_email = g.grade_student_epita_email_ref 
where s.student_population_code_ref = 'DSA' 
order by full_name
	

-- attendance percentage for a student 

select (sum_atten/total_atten::float)*100 attendance_percentage, res.attendance_student_ref, res.attendance_course_ref, res.attendance_population_year_ref from
(
select count(1) as total_atten, sum(s.attendance_presence) as sum_atten,
s.attendance_student_ref, s.attendance_course_ref, s.attendance_population_year_ref
from attendance as s
where s.attendance_student_ref='jamal.vanausdal@epita.fr'
group by s.attendance_student_ref, s.attendance_course_ref, s.attendance_population_year_ref
) res
order by attendance_percentage

-- avg grade for DSA students

select s.student_population_code_ref, avg(g.grade_score)
from grades g inner join students s on g.grade_student_epita_email_ref = s.student_epita_email 
where s.student_population_code_ref = 'DSA' 
group by s.student_population_code_ref  


-- All student average grade

select c.contact_first_name || ' ' || c.contact_last_name as full_name, s.student_epita_email as email, avg(g.grade_score) as average
from contacts c inner join students s on c.contact_email = s.student_contact_ref 
inner join grades g on s.student_epita_email = g.grade_student_epita_email_ref 
group by full_name, email
order by average desc


--list the course taught by teacher 
select t.teacher_epita_email as email, s.session_course_ref as ref, p.program_assignment as program
from teachers t right join sessions s on t.teacher_epita_email = s.session_prof_ref 
right join programs p on s.session_course_rev_ref = p.program_course_rev_ref group by program ,email, ref


-- find the teachers who are not giving any courses
select distinct t.teacher_epita_email as email
from teachers t full outer join  sessions s on t.teacher_epita_email = s.session_prof_ref 
where s.session_prof_ref is null order by email



