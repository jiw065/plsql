Create table Scores (Id int, Score DECIMAL(3,2));
Truncate table Scores;
insert into Scores (Id, Score) values ('1', '3.5');
insert into Scores (Id, Score) values ('2', '3.65');
insert into Scores (Id, Score) values ('3', '4.0');
insert into Scores (Id, Score) values ('4', '3.85');
insert into Scores (Id, Score) values ('5', '4.0');
insert into Scores (Id, Score) values ('6', '3.65');
insert into Scores (Id, Score) values ('7', '4.0');

select * from scores; 



select s.score, c.rn from scores s ,(select rownum rn, sc.cnt, sc.score from 
                                      (select count(id) cnt, score from scores 
                                      group by score order by score desc) sc)c  
where s.score = c.score
order by s.score desc; 



-- Write your MySQL query statement below

select s.score,cast(c.rn as signed) rank from scores s ,(select (@row_number:=@row_number + 1) rn, sc.cnt, sc.score from 
                                      (select count(id) cnt, score from scores 
                                      group by score order by score desc) as sc,(SELECT @row_number:=0) AS t)c  
where s.score = c.score
order by s.score desc; 

