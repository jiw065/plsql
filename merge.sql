
-- merge
SELECT * FROM EMPLOYEES e where e.commission_pct is not null; 
select * from user_tables; 

select * from departments d, locations l where d.location_id = l.location_id
select * from bonuses;
ALTER TABLE BONUSES ADD ( MANAGER_ID NUMBER(5));
DELETE FROM BONUSES
CREATE TABLE bonuses (employee_id NUMBER, bonus NUMBER DEFAULT 100);

INSERT INTO bonuses(employee_id,MANAGER_ID)
   (SELECT e.employee_id,E.MANAGER_ID FROM employees e where e.job_id = 'SA_REP' and e.commission_pct > 0.15 ); 

MERGE INTO BONUSES B -- source table
USING (SELECT * FROM EMPLOYEES WHERE MANAGER_ID = 148 AND COMMISSION_PCT IS NOT NULL) E --target table
ON (B.EMPLOYEE_ID = E.EMPLOYEE_ID) -- connection
WHEN MATCHED THEN UPDATE SET B.BONUS = B.BONUS*(1+E.COMMISSION_PCT*2) -- update
  DELETE WHERE E.SALARY > 10000 -- delete
WHEN NOT MATCHED THEN INSERT ( B.EMPLOYEE_ID,B.BONUS,B.MANAGER_ID) -- insert 
  VALUES (E.EMPLOYEE_ID,100*(1+E.COMMISSION_PCT),E.MANAGER_ID) WHERE E.SALARY < 10000; 
  
SELECT * FROM EMPLOYEES E, BONUSES B WHERE E.EMPLOYEE_ID = B.EMPLOYEE_ID AND E.SALARY >10000
  
MERGE INTO BONUSES B
USING (SELECT * FROM EMPLOYEES WHERE  COMMISSION_PCT IS NOT NULL ) E
ON (B.EMPLOYEE_ID = E.EMPLOYEE_ID)
WHEN MATCHED THEN UPDATE SET B.BONUS = E.SALARY*E.COMMISSION_PCT 
  DELETE WHERE E.SALARY > 10000
WHEN NOT MATCHED THEN INSERT (B.EMPLOYEE_ID,B.BONUS,B.MANAGER_ID) 
  VALUES (E.EMPLOYEE_ID, E.SALARY*E.COMMISSION_PCT, E.MANAGER_ID)
  WHERE E.SALARY < 10000;  
  
  
MERGE ON --SOURCE TABLE
USING -- TARGET TABLE
ON -- CONDITION FOR BINDING
WHEN MATCHED THEN UPDATE SET -- UPDATE VALUE
  DELETE -- DELETE RECORDS
WHEN NOT MATCHED THEN INSERT -- COLUMNS
  VALUES -- INSERTED VALUES
  WHERE -- INSERT CONDITION    
  
CREATE OR REPLACE TRIGGER AFTER_UPDATE_BONUS 
AFTER UPDATE ON BONUSES
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.put_line('UPDATE '||:NEW.EMPLOYEE_ID || ' BONUS FROM '||:OLD.BONUS ||' TO '||:NEW.BONUS);
END; 
/  
CREATE OR REPLACE TRIGGER AFTER_DELETE_BONUS
AFTER DELETE ON BONUSES
FOR EACH ROW
  BEGIN 
     DBMS_OUTPUT.put_line('DELETE '||:OLD.EMPLOYEE_ID || ' BONUS '||:OLD.BONUS);
  END;
/  
CREATE OR REPLACE TRIGGER AFTER_INSERT_BONUS
AFTER INSERT ON BONUSES
FOR EACH ROW
  BEGIN
    DBMS_OUTPUT.put_line('INSERT '||:NEW.EMPLOYEE_ID || ' BONUS '||:NEW.BONUS);
  END;  
/

select * from employees e where e.employee_id = 888 
                                       

       
MERGE INTO EMPLOYEES E 
USING (SELECT 888 EID FROM DUAL) A
ON (E.EMPLOYEE_ID = A.EID)
WHEN MATCHED THEN UPDATE SET E.FIRST_NAME = 'EIGHTY', E.LAST_NAME ='TESTer'
WHEN NOT MATCHED THEN INSERT (EMPLOYEE_ID,
                                       FIRST_NAME,
                                       LAST_NAME,
                                       EMAIL,
                                       PHONE_NUMBER,
                                       HIRE_DATE,
                                       JOB_ID,
                                       SALARY,
                                       COMMISSION_PCT,
                                       MANAGER_ID,
                                       DEPARTMENT_ID) values (A.EID, 'EIGHT',
                                              'TEST',
                                              'test888@gmail.com',
                                              '12345',
                                              sysdate,
                                              'SA_REP',
                                              8888,
                                              null,
                                              147,
                                              80 );
  
