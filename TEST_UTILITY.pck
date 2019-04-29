create or replace package TEST_UTILITY is

  -- Author  : AMBER
  -- Created : 2019/4/14 18:06:01
  -- Purpose : STORES THE TEST FUNCTION AND PROCEDURES
  
  -- Public type declarations
TYPE T_EMP_SALARY IS TABLE OF NUMBER(8,2)
INDEX BY VARCHAR2(5) ; 
 
 
TYPE EMP_EMAIL IS RECORD (EMPID EMPLOYEES.EMPLOYEE_ID%TYPE, EMAIL EMPLOYEES.EMAIL%TYPE);
TYPE EINFO IS RECORD ( EID EMPLOYEES.EMPLOYEE_ID%TYPE,
                       LN EMPLOYEES.LAST_NAME%TYPE,
                       SAL EMPLOYEES.SALARY%TYPE                   
                      );
                      
TYPE MEMP_INFO IS RECORD (TITLE VARCHAR2(10),
                          EID EMPLOYEES.EMPLOYEE_ID%TYPE,
                          ELN EMPLOYEES.LAST_NAME%TYPE,
                          ESAL EMPLOYEES.SALARY%TYPE);    
                                            
TYPE ELIST IS TABLE OF EINFO;
TYPE T_EMP_EMAIL IS TABLE OF EMP_EMAIL;
TYPE MLIST IS TABLE OF MEMP_INFO;

                     
TYPE EMC IS REF CURSOR RETURN EMP_EMAIL; 
TYPE ECV IS REF CURSOR;





 

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
/*********************************************************************
*  Object: BOOLEAN_TO_CHAR
*  Type: function
*  Purpose: Convert boolean type variable to varchar type
*  Parameters:
*     p_boolean: boolean variable needs to convert
*  Return:
*     v_char: converted varchar2 value to represent p_boolean       
********************************************************************/  

  FUNCTION GET_EMP_SAL (P_DEPT_ID IN EMPLOYEES.DEPARTMENT_ID%TYPE)
  RETURN T_EMP_SALARY;
  
  PROCEDURE GET_EMP_SAL (P_DEPT_ID IN EMPLOYEES.DEPARTMENT_ID%TYPE);
  
  
 /**
 EMPLOYEE_ID    NUMBER(6)                     Primary key of employees table.                                                                                                                                                           
FIRST_NAME     VARCHAR2(20) Y                First name of the employee. A not null column.                                                                                                                                            
LAST_NAME      VARCHAR2(25)                  Last name of the employee. A not null column.                                                                                                                                             
EMAIL          VARCHAR2(25)                  Email id of the employee                                                                                                                                                                  
PHONE_NUMBER   VARCHAR2(20) Y                Phone number of the employee; includes country code and area code                                                                                                                         
HIRE_DATE      DATE                          Date when the employee started on this job. A not null column.                                                                                                                            
JOB_ID         VARCHAR2(10)                  Current job of the employee; foreign key to job_id column of the
jobs table. A not null column.                                                                                            
SALARY         NUMBER(8,2)  Y                Monthly salary of the employee. Must be greater
than zero (enforced by constraint emp_salary_min)                                                                                          
COMMISSION_PCT NUMBER(2,2)  Y                Commission percentage of the employee; Only employees in sales
department elgible for commission percentage                                                                                
MANAGER_ID     NUMBER(6)    Y                Manager id of the employee; has same domain as manager_id in
departments table. Foreign key to employee_id column of employees table.
(useful for reflexive joins and CONNECT BY query) 
DEPARTMENT_ID  NUMBER(4)    Y                Department id where employee works; foreign key to department_id
column of the departments table
**/
  
  FUNCTION INSERT_EMPLOYEE(P_EMPID NUMBER DEFAULT NULL, P_LNAME VARCHAR2, P_FNAME VARCHAR2,
                           P_EMAIL VARCHAR2,P_PNUM VARCHAR2,P_JOBID VARCHAR2,
                           P_SALARY NUMBER,P_DEPTID NUMBER)
  RETURN EMPLOYEES.EMPLOYEE_ID%TYPE; 
  
  FUNCTION GET_EMAIL_FROM_DEPT(P_DEPTID IN NUMBER)
  RETURN T_EMP_EMAIL PIPELINED; 
  
  FUNCTION GET_EMAIL_FROM_DEPT2 (P_DEPTID IN NUMBER)
  RETURN EMC; 
  
  FUNCTION GET_MANAGER_INFO(MINF ECV)
  RETURN MLIST PIPELINED;
  
  FUNCTION GET_MANAGER_INFO2(P_DEPTID IN NUMBER)
  RETURN ECV;
  
  FUNCTION GET_MANAGER_INFO3
  RETURN ECV;
  
  PROCEDURE INSERT_JOB_TABLE( P_ID IN VARCHAR2,P_TITLE VARCHAR2,P_MIN IN NUMBER, P_MAX IN NUMBER, TABLE_NAME IN VARCHAR2);
   

end TEST_UTILITY;
/
create or replace package body TEST_UTILITY is

/*  -- Private type declarations
   TYPE T_EMP_SALARY IS TABLE OF NUMBER(8,2)
   INDEX BY VARCHAR2(5) ; */
  
  -- Private constant declarations
 -- <ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  FUNCTION GET_EMP_SAL (P_DEPT_ID IN EMPLOYEES.DEPARTMENT_ID%TYPE)
  RETURN T_EMP_SALARY
  IS
   A_EMP_SAL T_EMP_SALARY;
  BEGIN
    FOR EMP IN (SELECT EMPLOYEE_ID, SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID = P_DEPT_ID)LOOP
      A_EMP_SAL(TO_CHAR(EMP.EMPLOYEE_ID)):= EMP.SALARY;
    END LOOP;
   RETURN A_EMP_SAL;
  END;
  
  PROCEDURE GET_EMP_SAL (P_DEPT_ID IN EMPLOYEES.DEPARTMENT_ID%TYPE)
  IS
   A_EMP_SAL T_EMP_SALARY;
   I VARCHAR2(5);
  BEGIN
   A_EMP_SAL := GET_EMP_SAL (P_DEPT_ID);
   I := A_EMP_SAL.FIRST;
   WHILE I IS NOT NULL LOOP
     DBMS_OUTPUT.put_line('SALARY OF '||I ||' IS '||A_EMP_SAL(I));
     I:= A_EMP_SAL.NEXT(I);
   END LOOP;
  END;

  FUNCTION INSERT_EMPLOYEE(P_EMPID NUMBER DEFAULT NULL, P_LNAME VARCHAR2, P_FNAME VARCHAR2,
                           P_EMAIL VARCHAR2,P_PNUM VARCHAR2,P_JOBID VARCHAR2,
                           P_SALARY NUMBER,P_DEPTID NUMBER)
  RETURN EMPLOYEES.EMPLOYEE_ID%TYPE
  IS
  V_EMPID EMPLOYEES.EMPLOYEE_ID%TYPE;
  DUP_PK EXCEPTION;
  PRAGMA EXCEPTION_INIT(DUP_PK,-2292);
  BEGIN
    V_EMPID := NVL(P_EMPID,EMPLOYEES_SEQ.NEXTVAL);
    INSERT INTO EMPLOYEES(EMPLOYEE_ID,
                        FIRST_NAME,
                        LAST_NAME,
                        EMAIL,
                        PHONE_NUMBER,
                        HIRE_DATE,
                        JOB_ID,
                        SALARY,
                        COMMISSION_PCT,
                        MANAGER_ID,
                        DEPARTMENT_ID)
    VALUES(V_EMPID,P_FNAME,P_LNAME,P_EMAIL,P_PNUM,SYSDATE,P_JOBID,P_SALARY,NULL,101,P_DEPTID);                     
    RETURN V_EMPID;
  EXCEPTION
    WHEN DUP_PK THEN
      DBMS_OUTPUT.put_line('DUP PRIMARY KEY : EMAIL, EMPID');
      DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace);
    
  END;
/*
  FUNCTION GET_EMAIL_FROM_DEPT(P_DEPTID IN NUMBER)
  RETURN T_EMP_EMAIL PIPELINED AS CURSOR K IS 
  SELECT EMPLOYEE_ID, EMAIL FROM EMPLOYEES WHERE DEPARTMENT_ID = P_DEPTID ;  
  BEGIN
    FOR REC IN K LOOP
      PIPE ROW(REC);
    END LOOP ;
  END;*/
  
  
  FUNCTION GET_EMAIL_FROM_DEPT(P_DEPTID IN NUMBER)
  RETURN T_EMP_EMAIL PIPELINED 
  IS
  BEGIN
    FOR E IN (SELECT EMPLOYEE_ID, EMAIL FROM EMPLOYEES WHERE DEPARTMENT_ID = P_DEPTID)LOOP
      PIPE ROW (E);
    END LOOP;  
  END;
  
  
  FUNCTION GET_EMAIL_FROM_DEPT2 ( P_DEPTID IN NUMBER)
  RETURN EMC
  IS
  CC EMC; 
  BEGIN
    OPEN CC FOR SELECT EMPLOYEE_ID, EMAIL FROM EMPLOYEES WHERE DEPARTMENT_ID = P_DEPTID;
    RETURN CC;  
  END; 
  
  FUNCTION GET_MANAGER_INFO(MINF ECV)
  RETURN MLIST PIPELINED
  IS
  EC ECV;
  ML MEMP_INFO;
  m EINFO; 
  EL Elist;
  BEGIN
    loop
      FETCH MINF INTO M.EID,M.LN,M.SAL,EC;
      ML.TITLE := 'MANAGER';
      ml.EID := m.EID;
      ml.ELN := m.LN;
      ml.ESAL := m.SAL;   
      EXIT WHEN MINF%NOTFOUND;
      PIPE ROW (ML);   
      FETCH EC bulk collect into EL;
      FOR J IN EL.FIRST .. EL.LAST LOOP
        ML.TITLE := 'EMPLOYEE';
        ML.EID :=EL(J).EID;
        ML.ELN :=EL(J).LN;
        ML.ESAL :=EL(J).SAL;
        PIPE ROW (ML); 
       
      END LOOP;
      
    END LOOP; 
    CLOSE MINF;
    return;   
  END; 
  
  
  FUNCTION GET_MANAGER_INFO2(P_DEPTID IN NUMBER)
  RETURN ECV
  IS
   EC ECV;
  BEGIN
    OPEN EC FOR SELECT DEPARTMENT_NAME, CURSOR(SELECT E.EMPLOYEE_ID, E.LAST_NAME 
                                               FROM EMPLOYEES E
                                               WHERE E.EMPLOYEE_ID IN (SELECT DISTINCT MANAGER_ID 
                                                                       FROM EMPLOYEES 
                                                                       WHERE DEPARTMENT_ID = D.DEPARTMENT_ID ) ) MANAGER
                FROM DEPARTMENTS D WHERE D.DEPARTMENT_ID = P_DEPTID;  
                
    RETURN EC;                                                                  
  
  END;
  
  
  FUNCTION GET_MANAGER_INFO3
  RETURN ECV
  IS
   EC ECV;
  BEGIN
    OPEN EC FOR SELECT DEPARTMENT_NAME, CURSOR(SELECT E.EMPLOYEE_ID, E.LAST_NAME 
                                               FROM EMPLOYEES E
                                               WHERE E.EMPLOYEE_ID IN (SELECT DISTINCT MANAGER_ID 
                                                                       FROM EMPLOYEES 
                                                                       WHERE DEPARTMENT_ID = D.DEPARTMENT_ID ) ) MANAGER
                FROM DEPARTMENTS D;  
                
    RETURN EC;                                                                  
  
  END;
  
   PROCEDURE INSERT_JOB_TABLE( P_ID IN VARCHAR2,P_TITLE VARCHAR2,P_MIN IN NUMBER, P_MAX IN NUMBER, TABLE_NAME IN VARCHAR2)
   IS
   BEGIN
     EXECUTE IMMEDIATE 'INSERT INTO '||TABLE_NAME||' VALUES( :1,:2, :3, :4)'
     USING P_ID, P_TITLE,P_MIN,P_MAX;   
   END;  
begin
NULL;
end TEST_UTILITY;
/
