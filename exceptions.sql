-- internally deinfed exception
DECLARE
cannot_insertnull EXCEPTION;
pragma exception_init(cannot_insertnull,-1400); -- ORA-01400 SO -1400 IS THE SQLCODE 
too_manyv EXCEPTION;
PRAGMA EXCEPTION_INIT(too_manyv, -1422);
v_insert varchar2(10) := null;
V_TEST VARCHAR2(100);

BEGIN 
 
 -- SELECT E.LAST_NAME INTO V_TEST FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = 80;

  
  insert into departments select 888,
                          null,
                          manager_id,
                          location_id from departments d where d.department_id = 80;  
  
EXCEPTION
  WHEN cannot_insertnull THEN
    
      dbms_output.put_line('v_insert is null!!');
     
  WHEN too_manyv THEN
      Dbms_Output.put_line ('returns more than more row'); 
  WHEN OTHERS THEN
         dbms_output.put_line(DBMS_UTILITY.format_error_stack);
         --ORA-01400: cannot insert NULL into ("HR"."DEPARTMENTS"."DEPARTMENT_NAME")

END;
/


-- predefined exception
DECLARE
V_TEST VARCHAR2(100);
err varchar2(100);
msg varchar2(512);
BEGIN
  SELECT E.LAST_NAME INTO V_TEST FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = 80;
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    err := sqlcode;
    msg := sqlerrm;
    Dbms_Output.put_line ('returns more than more row');
    dbms_output.put_line (err||' '||msg);
   
END; 



-- user-define exception
declare
sal_too_high exception;
v_sal employees.salary%type;
v_max_sal constant number(5):= 10000;
begin
  for e in (select salary*1.2 sal from employees where department_id = 100) loop
    v_sal := e.sal;
     if  v_sal >= v_max_sal then
       raise sal_too_high;
     end if;
  end loop;

exception
  when sal_too_high then
  dbms_output.put_line( 'v_sal '|| v_sal||' exceeds '||v_max_sal );
end; 
/

-- use applcaition error to rasie user-defined excpeition
declare
sal_too_high exception;
v_sal employees.salary%type;
v_max_sal constant number(5):= 10000;
pragma exception_init(sal_too_high,-20000);
begin
  for e in (select salary*1.2 sal from employees where department_id = 100) loop
    v_sal := e.sal;
     if  v_sal >= v_max_sal then
       raise_application_error(-20000,'salary is too high');
     end if;
     DBMS_OUTPUT.put_line('END LOOP');
  end loop;

exception
  when sal_too_high then
  dbms_output.put_line( 'v_sal '|| v_sal||' exceeds '||v_max_sal );
  dbms_output.put_line(dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);
end; 
/


-- retrying tranaction after handling exception
declare
sal_too_high exception;
v_sal employees.salary%type;
v_max_sal constant number(5):= 10000;
begin
  for e in (select salary*1.2 sal from employees where department_id = 100) loop
    v_sal := e.sal;
    for i in 1..5 loop
        BEGIN
          savepoint trans_start; 
          if  v_sal >= v_max_sal then
              raise sal_too_high;
          end if;
          exit;  
        EXCEPTION
         when sal_too_high then
         V_SAL :=V_sal-1000; 
         rollback to trans_start; 
        END;   
    end loop;
     if  v_sal >= v_max_sal then
              raise sal_too_high;
     end if; 
     dbms_output.put_line(v_sal);
  end loop;
exception
  when sal_too_high then
  dbms_output.put_line( 'v_sal '|| v_sal||' exceeds '||v_max_sal );
  dbms_output.put_line(dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace);  
  
end; 
/






-- continue transaction after handling 

declare
sal_too_high exception;
v_sal employees.salary%type;
v_max_sal constant number(5):= 10000;
begin
  
  for e in (select salary*1.2 sal from employees where department_id = 100) loop
    
    BEGIN
    v_sal := e.sal;
     if  v_sal >= v_max_sal then
       raise sal_too_high;
     end if;
    EXCEPTION
       when sal_too_high then
         V_SAL:=v_max_sal;
         raise;  -- when raise the exception go to outer block exception
    END;  
     DBMS_OUTPUT.put_line(V_SAL);
  end loop;
   DBMS_OUTPUT.put_line('END LOOP');
exception
  when sal_too_high then
  dbms_output.put_line( 'v_sal '|| v_sal||' exceeds '||v_max_sal );
end; 
/


declare
sal_too_high exception;
v_sal employees.salary%type;
v_max_sal constant number(5):= 10000;
begin
  
    v_sal := 18000;
    savepoint test_sv;
     if  v_sal >= v_max_sal then
       raise sal_too_high;
     end if;
      DBMS_OUTPUT.put_line(V_SAL);

exception
  when sal_too_high then
  dbms_output.put_line( 'v_sal '|| v_sal||' exceeds '||v_max_sal );
  v_sal := v_max_sal; 
  rollback to test_sv; 
end; 
/
-- function to retry the exception
create or replace function change_sal(p_sal employees.salary%type)
return employees.salary%type
is
v_sal employees.salary%TYPE;
v_max_sal constant number(5):= 10000;
sal_too_high exception;
BEGIN
  v_sal := p_sal;
  for i in 1 ..5 loop
    begin
    savepoint func_test;
    IF v_SAL > v_max_sal then 
      raise sal_too_high;
    end if;
    exit;  
    exception
     when sal_too_high then
       v_sal := v_sal -900;
       rollback to func_test; 
    end;
  end loop;
  if v_sal > v_max_sal then
    raise_application_error(-20001, 'salary too high');
  end if;  
  return v_sal;     
 
END;

declare
sal_too_high exception;
v_sal employees.salary%TYPE;
pragma exception_init(sal_too_high,-20001);
begin
  for e in (select salary*1.2 sal from employees where department_id = 100  ) loop
    v_sal := change_sal(e.sal);
    dbms_output.put_line(v_sal);
  end loop;
  
exception
  when  sal_too_high then
     dbms_output.put_line( 'v_sal exceeds max sal');
end;
/ 



