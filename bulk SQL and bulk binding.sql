/*TYPE EINFO IS RECORD ( EID EMPLOYEES.EMPLOYEE_ID%TYPE,
                       LNA EMPLOYEES.LAST_NAME%TYPE,
                       SAL EMPLOYEES.SALARY%TYPE                   
                      );
TYPE ELIST IS TABLE OF EINFO;*/
                      
CREATE TABLE EMP_SAL AS SELECT E.EMPLOYEE_ID,E.SALARY FROM EMPLOYEES E WHERE 1 =2 ;


--  FORALL

DECLARE
EL test_utility.ELIST;
ER TEST_UTILITY.EINFO;
BEGIN
  SELECT E.EMPLOYEE_ID,E.LAST_NAME,E.SALARY BULK COLLECT INTO EL FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = 80;
  FORALL I IN EL.FIRST .. EL.LAST
   INSERT INTO EMP_SAL(EMPLOYEE_ID, SALARY) VALUES (EL(I).EID, EL(I).SAL);   

END;
/

SELECT * FROM EMP_SAL; 
select * from employees e where e.employee_id = 216

-- ATTRIBUTES: BULKEXCEPTION AND BULKCOUNT

-- WHERE ARE THE EXCEPTIONS 
DECLARE
TYPE MAILS IS TABLE OF EMPLOYEES.EMAIL%TYPE;
ML MAILS := MAILS('123@TEST.COM','123@TEST.COM','456@TEST.COM','789@TEST.COM','456@TEST.COM');
N NUMBER(2) := 1; 
bad_bulk_dml exception;
pragma exception_init(bad_bulk_dml,-24381);
error_message varchar2(512);
BEGIN
  FORALL I IN ML.FIRST .. ML.LAST
  SAVE EXCEPTIONS
    INSERT INTO EMPLOYEES SELECT EMPLOYEES_SEQ.NEXTVAL,
                          FIRST_NAME,
                          LAST_NAME,
                          ML(I),
                          PHONE_NUMBER,
                          HIRE_DATE,
                          JOB_ID,
                          SALARY,
                          COMMISSION_PCT,
                          MANAGER_ID,
                          DEPARTMENT_ID FROM EMPLOYEES WHERE EMPLOYEE_ID = 888;
exception
  when bad_bulk_dml then
  FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
      error_message := SQLERRM(-(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
      DBMS_OUTPUT.PUT_LINE (error_message);
      DBMS_OUTPUT.PUT_LINE('Bad statement #: ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
     END LOOP;
END; 
/


-- BULK COLLECT INTO (SELECT&FETCH)
DECLARE
CURSOR C1(PID NUMBER) IS SELECT E.EMPLOYEE_ID, E.LAST_NAME, E.SALARY FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = PID; 
TYPE C2 IS REF CURSOR RETURN TEST_UTILITY.EINFO;
C C2; 
TYPE EINFO IS RECORD ( EID EMPLOYEES.EMPLOYEE_ID%TYPE,
                       LNA EMPLOYEES.LAST_NAME%TYPE,
                       SAL EMPLOYEES.SALARY%TYPE                   
                      );
TYPE ELIST IS TABLE OF EINFO;

ELL ELIST;
EL2 ELIST;

type eidlist is table of employees.employee_id%type;
type lnlist is table of EMPLOYEES.LAST_NAME%TYPE;
type sallist is table of EMPLOYEES.SALARY%TYPE;

eidl eidlist;
lnl lnlist;
sall sallist;
 

BEGIN
  OPEN C FOR SELECT E.EMPLOYEE_ID, E.LAST_NAME, E.SALARY FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = 100;
  -- FETCH REF CURSOR
 FETCH C BULK COLLECT INTO ELL; 
  
  FOR I IN ELL.FIRST..ELL.LAST LOOP
    DBMS_OUTPUT.put_line(ELL(I).EID||' '||ELL(I).LNA);
  END LOOP;
 CLOSE C;
  
  DBMS_OUTPUT.put_line('---------------------------------');
  
    OPEN C1(100); 
  FETCH C1 BULK COLLECT INTO EIDL,LNL,SALL; 

  FOR I IN EIDL.FIRST..EIDL.LAST LOOP
    DBMS_OUTPUT.put_line(EIDL(I)||' '||LNL(I)||' '||SALL(I));
  END LOOP;
  CLOSE C1; 
  DBMS_OUTPUT.put_line('---------------------------------');
  
  -- FETCH CURSOR
   
  OPEN C1(50);  
  FETCH C1 BULK COLLECT INTO EL2 LIMIT 5;  
   
  FOR I IN EL2.FIRST..EL2.LAST LOOP
    DBMS_OUTPUT.put_line(EL2(I).EID||' '||EL2(I).LNA);
  END LOOP;
  
  
  CLOSE C1;  

END;
/ 



-- RETURNING BULK COLLECT INTO

DECLARE
TYPE EINFO IS RECORD ( EID EMPLOYEES.EMPLOYEE_ID%TYPE,
                       LNA EMPLOYEES.LAST_NAME%TYPE,
                       SAL EMPLOYEES.SALARY%TYPE                   
                      );
TYPE ELIST IS TABLE OF EINFO;
RECV_LIST ELIST;
BEGIN
  UPDATE EMPLOYEES E SET E.SALARY = E.SALARY+100 WHERE E.DEPARTMENT_ID = 80
  RETURNING E.EMPLOYEE_ID,E.LAST_NAME,E.SALARY BULK COLLECT INTO RECV_LIST;
  
  FOR I IN RECV_LIST.FIRST .. RECV_LIST.LAST LOOP
    DBMS_OUTPUT.put_line('UPD '||RECV_LIST(I).LNA ||' '||RECV_LIST(I).SAL);
  
  END LOOP;
  
  DELETE FROM EMPLOYEES E WHERE E.EMPLOYEE_ID > 210 
  RETURNING  E.EMPLOYEE_ID,E.LAST_NAME,E.SALARY BULK COLLECT INTO RECV_LIST;
  
  FOR I IN RECV_LIST.FIRST .. RECV_LIST.LAST LOOP
    DBMS_OUTPUT.put_line('DEL '||RECV_LIST(I).LNA ||' '||RECV_LIST(I).SAL);
  
  END LOOP;
  

END; 
/


-- RETURNING BULK COLLECT INTO WITH FOR ALL

DECLARE
TYPE EINFO IS RECORD ( EID EMPLOYEES.EMPLOYEE_ID%TYPE,
                       LNA EMPLOYEES.LAST_NAME%TYPE,
                       SAL EMPLOYEES.SALARY%TYPE                   
                      );
TYPE ELIST IS TABLE OF EINFO;
RETURN_LIST ELIST;
UPD_LIST ELIST;
BEGIN
  SELECT EMPLOYEE_ID, LAST_NAME, SALARY*1.2 BULK COLLECT INTO UPD_LIST FROM EMPLOYEES WHERE DEPARTMENT_id = 100;
  FORALL I IN UPD_LIST.FIRST ..UPD_LIST.LAST 
    UPDATE EMPLOYEES E SET E.SALARY =UPD_LIST(I).SAL WHERE E.DEPARTMENT_ID = 100 AND E.EMPLOYEE_ID = UPD_LIST(I).EID
    RETURNING E.EMPLOYEE_ID,E.LAST_NAME,E.SALARY BULK COLLECT INTO RETURN_LIST;  
    
    FOR I IN UPD_LIST.FIRST .. UPD_LIST.LAST LOOP
    DBMS_OUTPUT.put_line('UPD_LIST '||UPD_LIST(I).LNA ||' '||UPD_LIST(I).SAL);
    END LOOP;

    FOR I IN RETURN_LIST.FIRST .. RETURN_LIST.LAST LOOP
    DBMS_OUTPUT.put_line('RETURN_LIST '||RETURN_LIST(I).LNA ||' '||RETURN_LIST(I).SAL||' '||SQL%BULK_ROWCOUNT(I));
    END LOOP; 

    ROLLBACK; 
END; 
/

SELECT * FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = 100;
SELECT * FROM EMP2  
-- ASSOCIATE ARRAY BULK BIND (????)

CREATE TABLE EMPS2 AS SELECT * FROM EMPLOYEES WHERE 1 =2; 
DECLARE
TYPE EMP_LIST IS TABLE OF EMPLOYEES%ROWTYPE;

EPL EMP_LIST;
BEGIN
  SELECT * BULK COLLECT INTO EPL FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = 100; 
  FORALL I IN EPL.FIRST .. EPL.LAST 
  INSERT INTO EMPS2 VALUES EPL(I);
  
END; 

SELECT * FROM EMPS2 ;

-- forall indices of and values of

DROP TABLE valid_orders;
CREATE TABLE valid_orders (
  cust_name  VARCHAR2(32),
  amount     NUMBER(10,2)
);
 
DROP TABLE big_orders;
CREATE TABLE big_orders AS
  SELECT * FROM valid_orders
  WHERE 1 = 0;
 
DROP TABLE rejected_orders;
CREATE TABLE rejected_orders AS
  SELECT * FROM valid_orders
  WHERE 1 = 0;
 
-- start ----

DECLARE
  SUBTYPE cust_name IS valid_orders.cust_name%TYPE;
  TYPE cust_typ IS TABLE OF cust_name;
  cust_tab  cust_typ;  -- Collection of customer names
 
  SUBTYPE order_amount IS valid_orders.amount%TYPE;
  TYPE amount_typ IS TABLE OF NUMBER;
  amount_tab  amount_typ;  -- Collection of order amounts
 
  TYPE index_pointer_t IS TABLE OF PLS_INTEGER;
 
  /* Collections for pointers to elements of cust_tab collection
     (to represent two subsets of cust_tab): */
 
  big_order_tab       index_pointer_t := index_pointer_t();
  rejected_order_tab  index_pointer_t := index_pointer_t();
 
  PROCEDURE populate_data_collections IS
  BEGIN
    cust_tab := cust_typ(
      'Company1','Company2','Company3','Company4','Company5'
    );
 
    amount_tab := amount_typ(5000.01, 0, 150.25, 4000.00, NULL);
  END;
 
BEGIN
  -- preparing 
  populate_data_collections;
 
  DBMS_OUTPUT.PUT_LINE ('--- Original order data ---');
 
  FOR i IN 1..cust_tab.LAST LOOP
    DBMS_OUTPUT.PUT_LINE (
      'Customer #' || i || ', ' || cust_tab(i) || ': $' || amount_tab(i)
    );
  END LOOP;
 
  -- Delete invalid orders:
 
  FOR i IN 1..cust_tab.LAST LOOP
    IF amount_tab(i) IS NULL OR amount_tab(i) = 0 THEN
      cust_tab.delete(i);
      amount_tab.delete(i);
    END IF;
  END LOOP;
 
  -- cust_tab is now a sparse collection.
 
  DBMS_OUTPUT.PUT_LINE ('--- Order data with invalid orders deleted ---');
 
  FOR i IN 1..cust_tab.LAST LOOP
    IF cust_tab.EXISTS(i) THEN
      DBMS_OUTPUT.PUT_LINE (
        'Customer #' || i || ', ' || cust_tab(i) || ': $' || amount_tab(i)
      );
    END IF;
  END LOOP;
 
  -- Using sparse collection, populate valid_orders table:
 
  FORALL i IN indices OF cust_tab
    INSERT INTO valid_orders (cust_name, amount)
    VALUES (cust_tab(i), amount_tab(i));
 

  populate_data_collections;  -- Restore original order data
 
  -- cust_tab is a dense collection again.

 
  FOR i IN cust_tab.FIRST .. cust_tab.LAST LOOP
    IF amount_tab(i) IS NULL OR amount_tab(i) = 0 THEN
      rejected_order_tab.EXTEND;
      rejected_order_tab(rejected_order_tab.LAST) := i; 
    END IF;
 
    IF amount_tab(i) > 2000 THEN
      big_order_tab.EXTEND;
      big_order_tab(big_order_tab.LAST) := i;
    END IF;
  END LOOP;
 
  \* Using each subset in a different FORALL statement,
     populate rejected_orders and big_orders tables: *\
 
  FORALL i IN VALUES OF rejected_order_tab
    INSERT INTO rejected_orders (cust_name, amount)
    VALUES (cust_tab(i), amount_tab(i));
 
  FORALL i IN VALUES OF big_order_tab
    INSERT INTO big_orders (cust_name, amount)
    VALUES (cust_tab(i), amount_tab(i));
END;
/

--select * from valid_orders
--truncate table valid_orders;

DROP TABLE emp_temp;
CREATE TABLE emp_temp (
  deptno NUMBER(2),
  job VARCHAR2(18)
);
 
CREATE OR REPLACE PROCEDURE p AUTHID DEFINER AS
  TYPE NumList IS TABLE OF NUMBER;
 
  depts          NumList := NumList(10, 20, 30);
  error_message  VARCHAR2(100);
 
BEGIN
  -- Populate table:
 
  INSERT INTO emp_temp (deptno, job) VALUES (10, 'Clerk');
  INSERT INTO emp_temp (deptno, job) VALUES (20, 'Bookkeeper');
  INSERT INTO emp_temp (deptno, job) VALUES (30, 'Analyst');
  COMMIT;
 
  -- Append 9-character string to each job:
 
  FORALL j IN depts.FIRST..depts.LAST
    UPDATE emp_temp SET job = job || ' (Senior)'
    WHERE deptno = depts(j);
 
EXCEPTION
  WHEN OTHERS THEN
    error_message := SQLERRM;
    DBMS_OUTPUT.PUT_LINE (error_message);
 
   --COMMIT;  -- Commit results of successful updates ; the change will not show up if there is no commit
    RAISE;
END;
/


BEGIN
  P;

END; 

SELECT * FROM emp_temp;
TRUNCATE TABLE EMP_TEMP; 

-- SQL%BULK_ROWCOUNT
DROP TABLE emp_temp;
CREATE TABLE emp_temp AS SELECT * FROM employees;

DECLARE
  TYPE NumList IS TABLE OF NUMBER;
  depts NumList := NumList(30, 50, 60);
BEGIN
  FORALL j IN depts.FIRST..depts.LAST
    DELETE FROM emp_temp WHERE department_id = depts(j);

  FOR i IN depts.FIRST..depts.LAST LOOP
    DBMS_OUTPUT.PUT_LINE (
      'Statement #' || i || ' deleted ' ||
      SQL%BULK_ROWCOUNT(i) || ' rows.'
    );
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Total rows deleted: ' || SQL%ROWCOUNT);
END;
/

SELECT * FROM EMPLOYEES SAMPLE(8); 

/*SELECT employee_id, last_name
  FROM employees
  ORDER BY employee_id
  OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;*/
  
  -- fetch bulk collect
  
