-- USE CONDITIONAL PREDICATES FOR TRIGGER
CREATE OR REPLACE TRIGGER AFTER_MOD_EMP_TRIG AFTER
INSERT OR UPDATE OR DELETE ON EMPLOYEES 
FOR EACH ROW
BEGIN
  CASE 
  WHEN INSERTING THEN
    Dbms_Output.put_line('Inserted eid '||:NEW.EMPLOYEE_ID);
  WHEN UPDATING THEN
    dbms_output.put_line('updated eid '||:OLD.EMPLOYEE_ID);
  WHEN  DELETING THEN 
    DBMS_OUTPUT.put_line('DELETED EDI '||:OLD.EMPLOYEE_ID);   
  END CASE; 
END; 
/

SELECT * FROM EMPLOYEES; 
BEGIN
  UPDATE EMPLOYEES E SET E.SALARY = E.SALARY +100 WHERE E.EMPLOYEE_ID = 101;
  INSERT INTO EMPLOYEES SELECT 666,
                        FIRST_NAME,
                        LAST_NAME,
                        'TEST666@GMAIL.COM',
                        PHONE_NUMBER,
                        HIRE_DATE,
                        JOB_ID,
                        SALARY,
                        COMMISSION_PCT,
                        MANAGER_ID,
                        DEPARTMENT_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = 888; 
  DELETE FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = 666;                      

END;

-- USE SELECT OF ON CONDITIONAL PREDICATES

CREATE OR REPLACE TRIGGER AFTER_UPDATE_EMP_IMP AFTER
UPDATE OF SALARY,HIRE_DATE,COMMISSION_PCT
ON EMPLOYEES
FOR EACH ROW
BEGIN
    IF UPDATING ('SALARY') THEN
      DBMS_OUTPUT.put_line('UPDATE SALARY FROM '||:OLD.SALARY||' TO '||:NEW.SALARY);
      DBMS_OUTPUT.put_line('DIFFERENCE IS '|| (:NEW.SALARY -:OLD.SALARY ));
    END IF;    
    IF UPDATING ('HIRE_DATE') THEN
      DBMS_OUTPUT.put_line('UPDATE HIRE_DATE FROM '||:OLD.HIRE_DATE||' TO '||:NEW.HIRE_DATE);
    END IF;  
    IF UPDATING ('COMMISSION_PCT') THEN
      DBMS_OUTPUT.put_line('UPDATE COMM');
    END IF;    

END;
/


BEGIN
  UPDATE EMPLOYEES E SET E.SALARY = E.SALARY*1.2 WHERE E.EMPLOYEE_ID = 101;
  UPDATE EMPLOYEES E SET E.SALARY = E.SALARY + 200, E.HIRE_DATE = SYSDATE -10, E.COMMISSION_PCT = 0.8 WHERE E.EMPLOYEE_ID = 102;  

END; 

-- updaet :NEW & CONDITIONAL TRIGGER & REFERENCING
CREATE OR REPLACE TRIGGER BEF_UPDATE_DEPARTMENT_NAME BEFORE
UPDATE ON DEPARTMENTS
REFERENCING NEW AS N  
FOR EACH ROW
WHEN (OLD.MANAGER_ID IS NULL)
BEGIN  
  :N.DEPARTMENT_NAME := :N.DEPARTMENT_NAME ||'('||:OLD.LOCATION_ID||')';  
END; 
/

UPDATE DEPARTMENTS D SET D.DEPARTMENT_NAME = 'T'||' '||D.DEPARTMENT_NAME;  

SELECT * FROM DEPARTMENTS; 

-- object_value trigger

-- PREPARE TABLES
BEGIN 
CREATE OR REPLACE TYPE OT AS OBJECT (EMPID NUMBER(6), ELN VARCHAR2(25), SALARY NUMBER(8,2));
CREATE TABLE OTT OF OT;
CREATE TABLE OTT_HIS(D DATE, OLD_OBJ OT, NEW_OBJ OT); 
INSERT INTO OTT SELECT E.EMPLOYEE_ID, E.LAST_NAME, E.SALARY FROM EMPLOYEES E WHERE E.EMPLOYEE_ID < 110;  

END;
/

SELECT * FROM OTT;
-- DEFINE TRIGGER
CREATE OR REPLACE TRIGGER AFTER_UPD_OTT AFTER
UPDATE ON OTT
FOR EACH ROW
BEGIN
  INSERT INTO OTT_HIS VALUES (SYSDATE, :OLD.OBJECT_VALUE, :NEW.OBJECT_VALUE); 

END;
/  


-- TEST

UPDATE OTT T SET T.SALARY = T.SALARY + 100;  
SELECT * FROM OTT_HIS; 

CREATE OR REPLACE TYPE OT2 AS OBJECT (EMPLOYEES%ROWTYPE);

-- instead of trigger

-- create view
CREATE OR REPLACE VIEW EMPLOYEE_DEPARTMENT_DETAIL AS
SELECT E.EMPLOYEE_ID, D.DEPARTMENT_ID,E.LAST_NAME,D.DEPARTMENT_NAME FROM EMPLOYEES E, DEPARTMENTS D
WHERE E.DEPARTMENT_ID = D.DEPARTMENT_ID;


-- create trigger
CREATE OR REPLACE TRIGGER UPDATE_EMP_DEPT_VIEW
INSTEAD OF UPDATE ON EMPLOYEE_DEPARTMENT_DETAIL
FOR EACH ROW
BEGIN
  IF :OLD.LAST_NAME != :NEW.LAST_NAME THEN
    UPDATE EMPLOYEES E SET E.LAST_NAME = :NEW.LAST_NAME WHERE E.EMPLOYEE_ID = :OLD.EMPLOYEE_ID;
  END IF;

   IF :OLD.DEPARTMENT_NAME != :NEW.DEPARTMENT_NAME THEN
    UPDATE DEPARTMENTS D SET D.DEPARTMENT_NAME = :NEW.DEPARTMENT_NAME WHERE D.DEPARTMENT_ID = :OLD.DEPARTMENT_ID;
  END IF;
END;
/

-- test
UPDATE EMPLOYEE_DEPARTMENT_DETAIL EDD SET EDD.LAST_NAME = 'TTT' , EDD.DEPARTMENT_NAME = 'T '||EDD.DEPARTMENT_NAME
WHERE EDD.EMPLOYEE_ID = 101;  

SELECT * FROM  EMPLOYEE_DEPARTMENT_DETAIL EDD WHERE EDD.EMPLOYEE_ID = 101; 

-- Create view:

-- Create type of nested table element:
 
CREATE OR REPLACE TYPE nte
AUTHID DEFINER IS
OBJECT (
  emp_id     NUMBER(6),
  lastname   VARCHAR2(25),
  job        VARCHAR2(10),
  sal        NUMBER(8,2)
);
/
 
CREATE OR REPLACE TYPE nte2
AUTHID DEFINER IS
RECORD (
  emp_id     NUMBER(6),
  lastname   VARCHAR2(25),
  job        VARCHAR2(10),
  sal        NUMBER(8,2)
);
/

-- Created type of nested table:
 
CREATE OR REPLACE TYPE emp_list_ IS
  TABLE OF nte;
/
 
CREATE OR REPLACE VIEW dept_view AS
  SELECT d.department_id, 
         d.department_name,
         CAST (MULTISET (SELECT e.employee_id, e.last_name, e.job_id, e.salary
                         FROM employees e
                         WHERE e.department_id = d.department_id
                        )
                        AS emp_list_
              ) emplist
  FROM departments d;
 
select *from  dept_view;



CREATE OR REPLACE VIEW dept_view AS
 SELECT d.department_id, 
         d.department_name,
         cursor(SELECT e.employee_id, e.last_name, e.job_id, e.salary
                         FROM employees e
                         WHERE e.department_id = d.department_id
                        ) emp_id                     
FROM departments d;

-- conpound trigger

-- MUTATING TABLE

CREATE OR REPLACE TRIGGER TEST_MUTATUING AFTER
UPDATE OF SALARY ON EMPLOYEES
FOR EACH ROW
DECLARE
AVG_SAL EMPLOYEES.SALARY%TYPE;
  
BEGIN
  SELECT AVG(SALARY) INTO AVG_SAL FROM EMPLOYEES; 
  IF (:NEW.SALARY > AVG_SAL) THEN
    RAISE_APPLICATION_ERROR()-20038,'EXCEED AVG SALARY';
  END IF;
END;   


UPDATE EMPLOYEES E SET E.SALARY = E.SALARY*1.1 WHERE E.Department_Id = 80;  

-- USE COMPOUND TRIGGER TO SOLVE THIS
CREATE OR REPLACE TRIGGER TEST_MUTATING_CP
FOR UPDATE OF SALARY ON EMPLOYEES
COMPOUND TRIGGER
-- INITAL SECTION
--TYPE AVG_SAL IS RECORD (ASAL EMPLOYEES.SALARY%TYPE, DEPTID EMPLOYEES.DEPARTMENT_ID%TYPE);
TYPE AVG_SAL_L IS TABLE OF EMPLOYEES.SALARY%TYPE
INDEX BY PLS_INTEGER;
ASL AVG_SAL_L;
ASAL EMPLOYEES.SALARY%TYPE;
BEFORE STATEMENT IS
BEGIN
FOR A IN (SELECT AVG(E.SALARY) AS1 ,E.DEPARTMENT_ID FROM EMPLOYEES E WHERE E.DEPARTMENT_ID IS NOT NULL GROUP BY E.DEPARTMENT_ID )LOOP
  ASL(A.DEPARTMENT_ID) := A.AS1;
END LOOP;
END BEFORE STATEMENT;
BEFORE EACH ROW IS
BEGIN
  ASAL := ASL(:NEW.DEPARTMENT_ID)*1.2;
  IF :NEW.SALARY > ASAL THEN
    DBMS_OUTPUT.put_line('EXCEED DEPARTMENT AVG*1.2 '|| ASAL);
    :NEW.SALARY := ASAL;
 END IF;
END BEFORE EACH ROW;
END;

-- CREATE AUDIT TABLE
CREATE TABLE employee_salaries (
  employee_id NUMBER NOT NULL,
  change_date DATE   NOT NULL,
  salary NUMBER(8,2) NOT NULL,
  ACTION VARCHAR2(10) NOT NULL,
  CONSTRAINT pk_employee_salaries PRIMARY KEY (employee_id, change_date),
  CONSTRAINT fk_employee_salaries FOREIGN KEY (employee_id)
    REFERENCES employees (employee_id)
      ON DELETE CASCADE)
/

select * from employee_salaries; 
select * from employees e where e.employee_id  between 145 and 160; 
-- COMPOUND TO BULK INSERT AUDIT DATA
CREATE OR REPLACE TRIGGER INSERT_EMP_AUDIT FOR
INSERT OR UPDATE on EMPLOYEES
COMPOUND TRIGGER
-- INITAL SECTION
IDS NUMBER(2) := 0;
TYPE EA_LIST IS VARRAY(5) OF employee_salaries%ROWTYPE;
EAL EA_LIST := EA_LIST();

PROCEDURE FLUSH_INTO_AUDIT(PEL IN OUT EA_LIST)
IS
BEGIN
  FORALL I IN PEL.FIRST .. PEL.LAST
  INSERT INTO employee_salaries VALUES PEL(I);
  PEL := EA_LIST();
END;

AFTER EACH ROW IS
BEGIN
   IDS := IDS+1;
   EAL.EXTEND;
   EAL(IDS).employee_id := :NEW.EMPLOYEE_ID;
   EAL(IDS).CHANGE_DATE := SYSDATE;
   EAL(IDS).SALARY := :NEW.SALARY;

   IF INSERTING THEN
       EAL(IDS).ACTION := 'INSERT';
   ELSIF UPDATING THEN
       EAL(IDS).ACTION := 'UPDATE';
   END IF;

   IF IDS = EAL.LIMIT THEN
     FLUSH_INTO_AUDIT(EAL);
     IDS := 0;
   END IF;

END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
  FLUSH_INTO_AUDIT(EAL);
END AFTER STATEMENT;
END;

-- trigger invokE subprogram

SELECT * FROM OTT;
-- DEFINE TRIGGER
CREATE OR REPLACE TRIGGER AFTER_UPD_OTT AFTER
UPDATE ON OTT
FOR EACH ROW
DECLARE  
v_char varchar2(30);
BEGIN
  INSERT INTO OTT_HIS VALUES (SYSDATE, :OLD.OBJECT_VALUE, :NEW.OBJECT_VALUE); 
  v_char := HELLOWORLD;
  DBMS_OUTPUT.put_line(V_CHAR);

END;
/  

-- TEST

UPDATE OTT T SET T.SALARY = T.SALARY + 100;  
SELECT * FROM OTT_HIS; 

-- look at trigger information

SELECT Trigger_type, Triggering_event, Table_name
FROM USER_TRIGGERS
WHERE Trigger_name = 'INSERT_EMP_AUDIT';


-- trigger calling subprogram and autonomous transaction

create table emp_log_sal (
employee_id number(6),
salary number(8,2),
time_stmp date,
constraint els_pk primary key (time_stmp)
);
alter table emp_log_sal add  (time_stmp date not null);
alter table emp_log_sal drop constraint ELS_PK; 
alter table emp_log_sal add constraint els_pk primary key (time_stmp,empid);
alter table emp_log_sal rename COLUMN employee_id to empid; 
alter table emp_log_sal modify empid number(6) not null; 

create or replace trigger test_tri after 
update on employees
for each row
declare
  procedure insert_log (empid in number, salary number)
  is
  pragma autonomous_transaction;
  begin
    insert into emp_log_sal(empid,
                            salary,
                            time_stmp)
    values (empid,salary,sysdate);                        
    commit; 
  end; 
    
begin
  insert_log(:new.employee_id, :new.salary);
end; 
/
select * from employees e 
update employees e set e.salary = e.salary +100 where e.employee_id in (259);

select * from emp_log_sal; 


create or replace procedure insert_log (empid in number, salary number)
  is
  pragma autonomous_transaction;
  begin
    insert into emp_log_sal(empid,
                            salary,
                            time_stmp)
    values (empid,salary,sysdate);                        
    commit; 
  end; 



create or replace trigger test_tri2 after 
update on employees
for each row
    
begin
  insert_log(:new.employee_id, :new.salary);
  test_utility.test_hello(:old.salary);
end; 
/
