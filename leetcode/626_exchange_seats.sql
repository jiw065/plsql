-- 626 exchange seats 

Create table seat(id int, student varchar(255));
Truncate table seat;
insert into seat (id, student) values ('1', 'Abbot');
insert into seat (id, student) values ('2', 'Doris');
insert into seat (id, student) values ('3', 'Emerson');
insert into seat (id, student) values ('4', 'Green');
insert into seat (id, student) values ('5', 'Jeames');
insert into seat (id, student) values ('6', 'Amber');
insert into seat (id, student) values ('7', 'Lily');
insert into seat (id, student) values ('8', 'Becky');
insert into seat (id, student) values ('9', 'Mandy');
delete from seat where id = '9'; 

select s.id, nvl((case when mod(s.id,2) = 0 then (select student from seat where id = s.id -1 )
                   else(select student from seat where id = s.id + 1 ) end ),s.student)  from seat s;

create or replace procedure swap_seat
is
temp_student seat.student%type;
type sl is table of seat%rowtype;
seat_list sl;
tail number(5); 
begin
select * bulk collect into seat_list from seat; 
if mod(seat_list.last,2)=1 then
  tail := seat_list.last-1;
else
  tail := seat_list.last;
end if; 
for i in 2..tail loop
  if mod(i,2) = 0 then
     temp_student := seat_list(i).student;
     seat_list(i).student := seat_list(i-1).student;
     seat_list(i-1).student := temp_student;
   end if;
   null;    
end loop; 

for i in seat_list.first .. seat_list.last loop
  dbms_output.put_line(seat_list(i).id ||' '||seat_list(i).student);
end loop;    
end;   
  
begin
  swap_seat;
end; 













