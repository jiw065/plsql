create or replace package score_utility is
end score_utility;

create or replace package body score_utility is
begin
  null;
end;  

drop table sc;
drop table course;
drop table teacher;
drop table student; 

create table student(
sno number(4) not null,
sname varchar2(20) not null,
sage date,
ssex varchar2(1),
constraint student_pk primary key (sno),
constraint check_student_ssex check (ssex in ('F','M')));
INSERT INTO student(sno,sname,sage,ssex) VALUES(1,'Zhang San',TO_DATE('1980-01-23','YYYY-MM-DD'),'M');
INSERT INTO student(sno,sname,sage,ssex) VALUES(2,'Li Si',TO_DATE('1982-12-12','YYYY-MM-DD'),'M');
INSERT INTO student(sno,sname,sage,ssex) VALUES(3,'Zhang Lan',TO_DATE('1981-09-09','YYYY-MM-DD'),'M');
INSERT INTO student(sno,sname,sage,ssex) VALUES(4,'Li Li',TO_DATE('1983-03-23','YYYY-MM-DD'),'F');
INSERT INTO student(sno,sname,sage,ssex) VALUES(5,'Wang Zhou',TO_DATE('1982-06-21','YYYY-MM-DD'),'M');
INSERT INTO student(sno,sname,sage,ssex) VALUES(6,'Wang Li',TO_DATE('1984-10-10','YYYY-MM-DD'),'F');
INSERT INTO student(sno,sname,sage,ssex) VALUES(8,'Wang Li',TO_DATE('1981-10-10','YYYY-MM-DD'),'M');

INSERT INTO student(sno,sname,sage,ssex) VALUES(7,'Liu Xiang',TO_DATE('1980-12-22','YYYY-MM-DD'),'F');
--------------------- 

create table teacher(
tno number(3) not null,
tname varchar2(20) not null,
constraint teacher_pk primary key (tno)
);

INSERT INTO teacher(tno,tname)VALUES(1,'Teacher Zhang');
INSERT INTO teacher(tno,tname)VALUES(2,'Teacher Wang');
INSERT INTO teacher(tno,tname)VALUES(3,'Teacher Li');
INSERT INTO teacher(tno,tname)VALUES(4,'Teacher Zhao');
INSERT INTO teacher(tno,tname)VALUES(5,'Teacher Liu');
INSERT INTO teacher(tno,tname)VALUES(6,'Teacher Xiang');
INSERT INTO teacher(tno,tname)VALUES(7,'Li Wenjing');
INSERT INTO teacher(tno,tname)VALUES(8,'Ye Ping');

--------------------- 

create table course (
cno number(2) not null,
cname varchar2(20) not null,
tno number(3),
constraint course_pk primary key (cno),
constraint teacher_fk foreign key (tno)
references teacher(tno) on delete set null
);

insert into course(cno,cname,tno) values(1,'MBA',3);
insert into course(cno,cname,tno) values(2,'Politics',1);
insert into course(cno,cname,tno) values(3,'UML',2);
insert into course(cno,cname,tno) values(4,'Database',5);
insert into course(cno,cname,tno) values(5,'Physics',8);


create table sc(
sno number(4) not null,
cno number(2) not null,
score number(5,2),
constraint student_fk foreign key (sno)
references student(sno) on delete cascade,
constraint course_fk foreign key (cno)
references course(cno) on delete cascade
);

INSERT INTO sc(sno,cno,score)VALUES(1,1,80);
INSERT INTO sc(sno,cno,score)VALUES(1,2,86); 
INSERT INTO sc(sno,cno,score)VALUES(1,3,83);
INSERT INTO sc(sno,cno,score)VALUES(1,4,89); 

INSERT INTO sc(sno,cno,score)VALUES(2,1,50); 
INSERT INTO sc(sno,cno,score)VALUES(2,2,36); 
--INSERT INTO sc(sno,cno,score)VALUES(2,3,43); 
INSERT INTO sc(sno,cno,score)VALUES(2,4,59);

INSERT INTO sc(sno,cno,score)VALUES(3,1,50); 
INSERT INTO sc(sno,cno,score)VALUES(3,2,96); 
--INSERT INTO sc(sno,cno,score)VALUES(3,3,73); 
INSERT INTO sc(sno,cno,score)VALUES(3,4,69);

INSERT INTO sc(sno,cno,score)VALUES(4,1,90);
INSERT INTO sc(sno,cno,score)VALUES(4,2,36);
INSERT INTO sc(sno,cno,score)VALUES(4,3,88); 
--INSERT INTO sc(sno,cno,score)VALUES(4,4,99);

INSERT INTO sc(sno,cno,score)VALUES(5,1,90); 
INSERT INTO sc(sno,cno,score)VALUES(5,2,96); 
INSERT INTO sc(sno,cno,score)VALUES(5,3,98); 
INSERT INTO sc(sno,cno,score)VALUES(5,4,99);

INSERT INTO sc(sno,cno,score)VALUES(6,1,70); 
INSERT INTO sc(sno,cno,score)VALUES(6,2,66); 
INSERT INTO sc(sno,cno,score)VALUES(6,3,58); 
INSERT INTO sc(sno,cno,score)VALUES(6,4,79);

INSERT INTO sc(sno,cno,score)VALUES(7,1,80); 
INSERT INTO sc(sno,cno,score)VALUES(7,2,76); 
INSERT INTO sc(sno,cno,score)VALUES(7,3,68); 
INSERT INTO sc(sno,cno,score)VALUES(7,4,59);
INSERT INTO sc(sno,cno,score)VALUES(7,5,89);
--------------------- 
--1、查询课程1的成绩 比 课程2的成绩 高 的所有学生的学号.

select c1.sno from sc c1, sc c2
where c1.cno = 1
and c2.cno = 2
and c1.sno = c2.sno
and c1.score > c2.score;

select a.sno from
(select sno,score from sc where cno=1) a,
(select sno,score from sc where cno=2) b
where a.score>b.score and a.sno=b.sno;

--2、查询平均成绩大于60分的同学的学号和平均成绩；

select sno,avg(score) from sc
having avg(score) > 60
group by sno;  

select sno,avg(score) as sscore from sc group by sno having avg(score) >60;

--3、查询所有同学的学号、姓名、选课数、总成绩
select s.sno, s.sname, count(c.cno),sum(c.score)
from student s, sc c
where c.sno (+)= s.sno
group by s.sno, s.sname;


select a.sno as 学号, b.sname as 姓名,
count(a.cno) as 选课数, sum(a.score) as 总成绩
from sc a, student b
where a.sno = b.sno
group by a.sno, b.sname;


--4、查询姓“李”的老师的个数；

select count(t.tno) from teacher t where (t.tname like '% Li'or t.tname like 'Li%');

--5、查询没学过“叶平”老师课的同学的学号、姓名；
select s.sno,s.sname from student s where not exists 
(select 1 from sc sc, teacher t, course c
where sc.sno = s.sno
and t.tno = c.tno
and sc.cno = c.cno
and t.tname = 'Ye Ping');

select student.sno,student.sname from student
where sno not in (select distinct(sc.sno) from sc,course,teacher
where sc.cno=course.cno and teacher.tno=course.tno and teacher.tname='Ye Ping');


--6、查询同时学过课程1和课程2的同学的学号、姓名
select s.sno,s.sname from student s, sc c
where c.sno = s.sno
and c.cno = 1
and exists (select 1 from sc where sno=s.sno and cno = 2);


select  s.sno,s.sname from student s, sc c1, sc c2
where s.sno = c1.sno
and s.sno = c2.sno
and c1.cno = 1
and c2.cno = 2;  

select  s.sno,s.sname from student s, sc c
where s.sno = c.sno
and c.cno = 1
intersect 
select  s.sno,s.sname from student s, sc c
where s.sno = c.sno
and c.cno = 2;

--7、查询学过“叶平”老师所教所有课程的所有同学的学号、姓名

select s.sno,s.sname from student s
where s.sno in (select distinct sno 
                from sc sc, course c, teacher t 
                where sc.cno = c.cno
                and c.tno = t.tno
                and t.tname = 'Ye Ping'
                ) ;

select a.sno, a.sname from student a, sc b
where a.sno = b.sno and b.cno in
(select c.cno from course c, teacher d where c.tno = d.tno and d.tname = 'Ye Ping');


--8、查询 课程编号1的成绩 比 课程编号2的成绩 高的所有同学的学号、姓名

select s.sno, s.sname from student s
where s.sno in (select distinct c1.sno from sc c1, sc c2
where c1.sno = c2.sno
and c1.cno = 1
and c2.cno = 2
and c1.score>c2.score
);


select a.sno, a.sname from student a,
(select sno, score from sc where cno = 1) b,
(select sno, score from sc where cno = 2) c
where b.score > c.score and b.sno = c.sno and a.sno = b.sno;

--9、查询所有课程成绩小于60分的同学的学号、姓名
select a.sno, a.sname from student a
where not exists (select 1 from sc c where c.sno = a.sno and c.score > 60);

select sno,sname from student
where sno not in (select distinct sno from sc where score > 60);

--10、查询所有课程成绩大于60分的同学的学号、姓名

select a.sno, a.sname from student a
where not exists (select 1 from sc c where c.sno = a.sno and c.score < 60);

select sno,sname from student
where sno not in (select distinct sno from sc where score < 60);


--11、查询没有学全所有课的同学的学号、姓名

select a.sno, a.sname from student a
where a.sno in (select sno from sc group by sno having count(distinct cno) < (select count(cno) from course));

select student.sno, student.sname
from student, sc
where student.sno = sc.sno
group by student.sno, student.sname
having count(sc.cno) < (select count(cno) from course);

--12、查询至少有一门课程 与 学号为1的同学所学课程 相同的同学的学号和姓名

select distinct s.sno, s.sname from student s, course c, sc sc
where s.sno = sc.sno
and sc.cno = c.cno
and c.cno in (select distinct cno from sc where sc.sno = 1)
and s.sno != 1; 

select distinct a.sno, a.sname
from student a, sc b
where a.sno <> 1 and a.sno=b.sno and
b.cno in (select cno from sc where sno = 1);


--13、把“sc”表中“刘老师”所教课的成绩都更改为此课程的平均成绩

update sc s set s.score = (select avg(score) from sc where sc.cno = s.cno group by cno)
where s.cno in (select distinct cno from course c, teacher t where c.tno = t.tno and t.tname = 'Teacher Liu');

select * from sc where cno in (select distinct cno from course c, teacher t where c.tno = t.tno and t.tname = 'Teacher Liu');


--14、查询和2号同学学习的课程完全相同的其他同学学号和姓名

select distinct s.sno, s.sname,sc.cno
from student s ,sc sc
where s.sno = sc.sno
and sc.cno = sc.cno
and s.sno <> 2
and sc.cno in (select distinct cno from sc where sno = 2)



select distinct s.sno,s.sname from sc c, student s
where c.cno in (select distinct cno from sc where sno = 2)
and s.sno = c.sno
and exists (select 1 from sc where sno = c.sno having sum(cno) = (select sum(cno) from sc where sno = 2) group by sno)
and s.sno <> 2; 


--15、删除学习“叶平”老师课的sc表记录
delete from sc where cno in (select c.cno from course c, teacher t where c.tno = t.tno and t.tname = 'Ye Ping'); 

--16、向sc表中插入一些记录，这些记录要求符合以下条件：
--将没有课程3成绩同学的该成绩补齐, 其成绩取所有学生的课程2的平均成绩

insert into sc(sno,
               cno,
               score)
select s.sno,3, (select avg(score) a from sc where cno = 2) score  from student s
where
not exists (select 1 from sc where cno = 3 and sno = s.sno );
               
--17、按平平均分从高到低显示所有学生的如下统计报表：
-- 学号,企业管理,马克思,UML,数据库,物理,课程数,平均分

select s.sno,
(select score from sc where cno = (select cno from course where cname = 'MBA') and sc.sno = s.sno) as "MBA",
(select score from sc where cno = (select cno from course where cname = 'Politics') and sc.sno = s.sno) as "Politics",
(select score from sc where cno = (select cno from course where cname = 'UML') and sc.sno = s.sno) as "UML",
(select score from sc where cno = (select cno from course where cname = 'Database') and sc.sno = s.sno) as "Database",
(select score from sc where cno = (select cno from course where cname = 'Physics') and sc.sno = s.sno) as "Physics",
(select count(cno) from sc where sno = s.sno) course_count, 
(select sum(score)/5 from sc where sno = s.sno) avg_score
from student s
order by avg_score desc;   


select s.sno,
max(case when s.cno = 1 then s.score end)as "MBA",
max(case when s.cno = 2 then s.score end)as "Politics",
max(case when s.cno = 3 then s.score end)as  "UML",
max(case when s.cno = 4 then s.score end)as "Database",
max(case when s.cno = 5 then nvl(s.score,0) end)as "Physics",
count(cno) c_count,
sum(score)/5 avg_sc
from sc s 
group by s.sno
order by avg_sc desc;

--18、查询各科成绩最高分和最低分：以如下形式显示：课程号，最高分，最低分
select c.cno, max(c.score), min(c.score) from sc c group by c.cno;  

----19、按各科平均成绩从低到高和及格率的百分数从高到低顺序

select c.cno,avg(c.score) avg_s, 
concat(round((select count(sno) from sc where nvl(score,0) >= 60 and cno = c.cno )/count(c.sno),3)*100,'%') pass_per 
from sc c group by c.cno
order by avg_s ,pass_per desc;


--20、查询如下课程平均成绩和及格率的百分数(用"1行"显示): 企业管理（001），马克思（002），UML （003），数据库（004） 

select 
avg (case when c.cno = 1 then c.score end) as "Management",
round(count(case when c.cno = 1 and c.score >= 60 then c.cno end)/count(case when c.cno = 1 then c.cno end )*100,2) pass_per_mba, 
avg (case when c.cno = 2 then c.score end) as "Politics",
round(count(case when c.cno = 2 and c.score >= 60 then c.cno end)/count(case when c.cno = 2 then c.cno end )*100,2) pass_per_poli, 
avg (case when c.cno = 3 then c.score end) as "UML",
round(count(case when c.cno = 3 and c.score >= 60 then c.cno end)/count(case when c.cno = 3 then c.cno end )*100,2) pass_per_uml, 
avg (case when c.cno = 4 then c.score end) as "Database",
round(count(case when c.cno = 4 and c.score >= 60 then c.cno end)/count(case when c.cno = 4 then c.cno end )*100,2) pass_per_db
from sc c;

--21、查询不同老师所教不同课程平均分, 从高到低显示
-- 张老师 数据库 88

select t.tname,c.cname,avg(s.score) avg_s from teacher t, sc s, course c
where t.tno = c.tno
and s.cno = c.cno
group by t.tname, c.cname
order by avg_s desc; 

--22、查询如下课程平均成绩在第3名到第6名之间的学生的成绩：
-- [学生ID],[学生姓名],企业管理,马克思,UML,数据库,平均成绩

 select s.sno,s.sname,
max(case when c.cno=1 then c.score end) as "MBA",
max(case when c.cno=2 then c.score end) as "MAX", 
max(case when c.cno=3 then c.score end) as "UML",
max(case when c.cno=4 then c.score end) as "DB",
sum(C.SCORE)/4 AVG_SC
from student s, sc c 
WHERE S.SNO = C.SNO
GROUP BY S.SNO,S.SNAME
ORDER BY AVG_SC DESC;


select * from table(hr.score_utility.create_score_table(top => 1,bottom => 7));

--23、统计打印各科成绩,各分数段人数:课程ID,课程名称,[100-85],[85-70],[70-60],[ <60]

select c.cno, c.cname, 
count(case when (sc.score between 85 and 100) then sc.cno end ) as "[100-85]",
count(case when (sc.score between 70 and 85) then sc.cno end ) as "[85-70]",
count(case when (sc.score between 60 and 70) then sc.cno end ) as "[70-60]",
count(case when (sc.score < 60) then sc.cno end ) as "[ <60]"
from course c, sc sc
where c.cno = sc.cno
group by c.cno,c.cname;


--24、查询学生平均分及其名次

select rownum as "rank", c.* from table(hr.score_utility.create_score_table) c;

select rownum as "rank",c.* from
( select s.sno,s.sname,
max(case when c.cno=1 then c.score end) as "MBA",
max(case when c.cno=2 then c.score end) as "MAX", 
max(case when c.cno=3 then c.score end) as "UML",
max(case when c.cno=4 then c.score end) as "DB",
sum(C.SCORE)/4 AVG_SC
from student s, sc c 
WHERE S.SNO = C.SNO
GROUP BY S.SNO,S.SNAME
ORDER BY AVG_SC DESC) c


--25、查询各科成绩前三名的记录:(不考虑成绩并列情况) 


select * from table(hr.score_utility.create_top3_table); 

select sc1.sno,c.cname,sc1.score from sc sc1,course c where sc1.cno = c.cno and c.cno = 2  order by sc1.score desc

----26、查询每门课程被选修的学生数 
select c.cname, (select count(cno) from sc where cno = c.cno) from course c;


--27、查询出只选修了一门课程的全部学生的学号和姓名
select s.sno,s.sname from student s
where exists (select 1 from sc where sno = s.sno group by sno having count(cno) = 3 ) 

--28、查询男生、女生人数 

SELECT
COUNT(CASE WHEN S.SSEX = 'F' THEN S.SNO END) FEAMALE,
COUNT(CASE WHEN S.SSEX = 'M' THEN S.SNO END) MALE
FROM STUDENT S;

SELECT
(SELECT COUNT(*) FROM STUDENT WHERE SSEX = 'F') FEAMALE,
(SELECT COUNT(*) FROM STUDENT WHERE SSEX = 'M') MALE
FROM DUAL;

--29、查询姓“张”的学生名单 

SELECT * FROM STUDENT WHERE SNAME LIKE 'Zhang %';

--30、查询同名同性学生名单，并统计同名人数
select S1.SNAME,COUNT(S1.SNAME) from student s1, student s2
where s1.sname = s2.sname
and s1.sno != s2.sno
GROUP BY S1.SNAME;


--31、1981年出生的学生名单(注：student表中sage列的类型是datetime) 

 SELECT * FROM STUDENT S WHERE TO_CHAR(S.SAGE,'YYYY') = '1981'; 
 
 
 --32、查询每门课程的平均成绩，结果按平均成绩升序排列，平均成绩相同时，按课程号降序排列 
 
 SELECT CNO, AVG(SCORE) AVG_S FROM SC
 GROUP BY CNO
 ORDER BY AVG_S, CNO DESC;  
 
 
 --33、查询平均成绩大于80的所有学生的学号、姓名和平均成绩
 SELECT S.SNO,S.SNAME, AVG(SCORE)  FROM STUDENT S, SC C
 WHERE S.SNO = C.SNO 
 GROUP BY S.SNO,S.SNAME
 HAVING AVG(SCORE) > 80;
 
 
 --34、查询 数据库 分数 低于60的学生姓名和分数
 SELECT s.sname, sc.score FROM STUDENT S, SC SC, COURSE C
 WHERE S.SNO = SC.SNO
 AND SC.CNO = C.CNO
 AND C.CNAME = 'Database'
 and sc.score < 60; 
 
 
 --35、查询所有学生的选课情况
 select s.sno,s.sname, 
 decode(count(case when sc.cno = 1 then sc.cno end),1,'Y','N') MBA,
 decode(count(case when sc.cno = 2 then sc.cno end),1,'Y','N') "MAX",
 decode(count(case when sc.cno = 3 then sc.cno end),1,'Y','N') UML,
 decode(count(case when sc.cno = 4 then sc.cno end),1,'Y','N') DB,
 decode(count(case when sc.cno = 5 then sc.cno end),1,'Y','N') PHYSICS 
 from student s, sc sc
 where sC.sno (+)= s.sno
 GROUP BY S.SNO,S.SNAME
 
 --36、查询成绩在70分以上的学生姓名、课程名称和分数
 SELECT S.SNAME,C.CNAME,SC.SCORE FROM STUDENT S, SC SC, COURSE C
 WHERE SC.SNO = S.SNO
 AND SC.CNO = C.CNO
 AND SC.SCORE > 70;
 
 --37、查询不及格的课程，并按课程号从大到小排列
 SELECT SC.* FROM SC SC
 WHERE SC.SCORE < 60
 ORDER BY SC.CNO DESC;
 
 
 --38、查询课程编号为3且课程成绩在80分以上的学生的学号和姓名
 SELECT  s.sno,s.sname,sc.score FROM STUDENT S, SC SC, COURSE C
 where s.sno = sc.sno
 and c.cno = sc.cno
 and sc.score >= 80
 and c.cno = 3 ;
 
 --39、求选了课程的学生人数 
select count(distinct sno) from sc;

--40、查询选修“叶平”老师所授课程的学生中，成绩最高的学生姓名及其成绩 

select s.sname,sc.score from sc sc, student s, course c
where sc.sno = s.sno 
and sc.cno = c.cno
and c.tno = (select tno from teacher where tname = 'Ye Ping')
and sc.score = (select max(score) from sc where cno = c.cno);







 
 
 
 
 
 
 
 
 
 
 
 
