
--collection
select *from employees; 
-- associated array


declare
type emp_list is table of employees%rowtype
index by pls_integer;

type e_info is record(email employees.email%type,lname employees.last_name%type);

type email_list is table of e_info
index by pls_integer;

type t is table of number
index by pls_integer;

elist emp_list;  
vt t;
emails email_list;
v_emp e_info;

begin 
  select * bulk collect into elist from employees;
  for e in elist.first .. elist.last loop
    --dbms_output.put_line(elist(e).email);
    null;
  end loop;
  
  for ee in (select * from employees) loop
    emails(ee.employee_id).email := ee.email;
    emails(ee.employee_id).lname := ee.last_name;  
  end loop;
  
  vt(1) :=100;
  vt(2) := 200;
  vt(3) := 300;
  
  vt.delete(2);
  
  
  dbms_output.put_line(vt(3)||' '||boolean_to_char(vt.exists(2)));
  v_emp := emails(102);
  
 dbms_output.put_line(emails(102).email||' ' || emails(102).lname ||' '|| emails.count||' '|| boolean_to_char(emails.exists(102)));
 
  
end;
/



-- varray

declare
type ea is varray(10) of employees%rowtype;
type nlist is varray(5) of number;
elist ea;

nll nlist := nlist(1,100,1000);
begin
  select * bulk collect into elist from employees where rownum <= 10;  
    for e in elist.first .. elist.last loop
     dbms_output.put_line(elist(e).email);
     null;
    end loop;
    NLL.EXTEND;
    NLL(4) := 999; 
   -- nll.extend(2,1);
    --nll.trim(2);
   -- nll.DELETE(2); -- cannot use delete for varray
    for i in nll.first .. nll.last loop
      dbms_output.put_line(nll(i) ||' '||nll.limit);
    end loop;
    
    --dbms_output.put_line(boolean_to_char(nll.exists(2))||' '||' '||nll(2)||' '||nll.limit||' '||nll.last||' '||nll.prior(nll.last-1));
end; 
/


-- nested table

declare
 type elist is table of employees%rowtype;
 dept80 elist;
 dept70 elist;
 temp elist;
 type nlist is table of number;
 nll nlist := nlist(100,200,1000,2000);
 
 
begin
    for i in nll.first .. nll.last loop
      dbms_output.put_line(nll(i));
    end loop;
    
    dbms_output.put_line(boolean_to_char(nll.exists(1)));
    
    
    select * bulk collect into dept80 from employees where department_id = 80;
    select * bulk collect into dept70 from employees where department_id = 70;
    
    for i in dept80.first .. dept80.last loop
      null;
    end loop;
end;
/

--create or replace view test_email as select employee_id, email from employees; 
-- records

declare
type emp is record (empid employees.employee_id%type, sal employees.salary%type); -- define record type via type record
e1 emp;
e2 employees%rowtype;  -- record variable represents the full columns of a table
cursor c is select employee_id, email from employees; 
e3 c%rowtype; -- record variable represents the partial columns of a table

-- return is optional
cursor c1 return emp is select employee_id, salary from employees where employee_id < 110;
e4 emp;
e5 emp;
e6 employees%rowtype;
e7 test_email%rowtype;
begin
  -- select into to assign values to record vaiable
  select employee_id, salary into e1 from employees where employee_id = 101;
  dbms_output.put_line('e1 '||e1.empid ||' '||e1.sal);
  -- can we use bulk collect into on record ?? NOOOO we cannot
  select * into e2 from employees where employee_id = 101;
   dbms_output.put_line('e2 '||e2.employee_id ||' '||e2.salary);
   -- can we fetch a cursor into record varaible without having return -- yes we can
   --select employee_id, email into e3 from employees where employee_id = 101;
   open c;
   fetch c into e3;
   dbms_output.put_line('e3 '||e3.employee_id ||' '||e3.email);
   close c; 
-- fetch from cursor
   open c1;
   fetch c1 into e4;
   dbms_output.put_line('e4 '||e4.empid ||' '||e4.sal);
   close c1;
   
   -- returning into a record viable for affected row
  --update employees e set e.salary = salary*1.2 where e.employee_id = 101 ;
    
  -- assign record vairables from one record variable
  e6 := e2;
  dbms_output.put_line('e6 '||e6.employee_id ||' '||e6.salary);

  -- reocrd variable represent full columns in a view
  e7 := e3;
  dbms_output.put_line('e7 '||e7.employee_id ||' '||e7.email);
  
  -- update table through record variable
  e6.salary := e6.salary*1.2; 
   update employees set row =  e6 where employee_id = 101 returning employee_id, salary into e5;
   dbms_output.put_line('e5 '||e5.empid ||' '||e5.sal);
   
   -- insert a record variable into a table
   
   e6.employee_id := 888;
   e6.email := 'test888@gmail.com';
   insert into employees values e6;

end;
