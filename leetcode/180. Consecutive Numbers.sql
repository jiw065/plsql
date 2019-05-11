Create table  Logs (Id int, Num int);
Truncate table Logs;
insert into Logs (Id, Num) values ('1', '1');
insert into Logs (Id, Num) values ('2', '1');
insert into Logs (Id, Num) values ('3', '1');
insert into Logs (Id, Num) values ('4', '2');
insert into Logs (Id, Num) values ('5', '1');
insert into Logs (Id, Num) values ('6', '2');
insert into Logs (Id, Num) values ('7', '2');

select * from logs;

select distinct l.num from (select num, count(num) cnt from logs group by num) cn, logs l
where cn.num = l.num
and cn.cnt >= 3
and exists (select 1 from logs l2 where l2.id in (l.id,l.id+1,l.id+2) and l.num = l2.num group by l2.num having count(l2.num) = 3);
-- better perforamance 
select distinct l1.num from logs l1, logs l2, logs l3
where l1.num = l2.num
and l2.num = l3.num
and l2.id = l1.id +1
and l3.id = l2.id +1;


