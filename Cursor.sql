-- implicit cursor
-- cursor attributes
DECLARE 
  V_EMP NUMBER(5);
BEGIN 
  SELECT EMPLOYEE_ID INTO V_EMP FROM EMPLOYEES WHERE EMPLOYEE_ID = 101;
  DBMS_OUTPUT.put_line(SQL%ROWCOUNT || boolean_to_char(SQL%FOUND));
  
  UPDATE EMPLOYEES E SET E.SALARY = 9999 WHERE E.EMPLOYEE_ID = 888;
  DBMS_OUTPUT.put_line(SQL%ROWCOUNT || boolean_to_char(SQL%FOUND));
  
  DELETE FROM EMPLOYEES E WHERE E.EMPLOYEE_ID = 999;
  DBMS_OUTPUT.put_line(boolean_to_char(SQL%NOTFOUND)|| boolean_to_char(SQL%FOUND));
  
END;
/


-- explicit cursor
DECLARE
CURSOR C IS SELECT EMPLOYEE_ID, SALARY FROM EMPLOYEES WHERE DEPARTMENT_ID = 100;
V_EID EMPLOYEES.EMPLOYEE_ID%TYPE;
V_SAL EMPLOYEES.SALARY%TYPE;
V_ES C%ROWTYPE;


CURSOR C1 IS SELECT * FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = 100;
V_EMP EMPLOYEES%ROWTYPE;

TYPE EMP_L IS TABLE OF EMPLOYEES%ROWTYPE;
TYPE ES_L IS TABLE OF C%ROWTYPE;
 
LEMP EMP_L;
LES ES_L;
BEGIN

  OPEN C;
  FETCH C INTO V_EID, V_SAL; 
  WHILE C%FOUND LOOP
    DBMS_OUTPUT.put_line('V_SAL '||V_EID ||' '||V_SAL);
    FETCH C INTO V_EID, V_SAL;   
  END LOOP;
  CLOSE C;

  OPEN C;
  LOOP
    FETCH C INTO V_ES;
    EXIT WHEN C%NOTFOUND;
    DBMS_OUTPUT.put_line('V_ES '||V_ES.EMPLOYEE_ID||' '||V_ES.SALARY);
  END LOOP;
  CLOSE C; 

   OPEN C1;
   FETCH C1 BULK COLLECT INTO LEMP;
   
   FOR I IN LEMP.FIRST .. LEMP.LAST LOOP
     DBMS_OUTPUT.put_line('LEMP '||LEMP(I).EMPLOYEE_ID||' '||LEMP(I).SALARY);
   END LOOP;
   CLOSE C1;
   
   OPEN C;
   FETCH C BULK COLLECT INTO LES;
   
   FOR I IN LES.FIRST .. LES.LAST LOOP
     DBMS_OUTPUT.put_line('LES '||LES(I).EMPLOYEE_ID||' '||LES(I).SALARY);
   END LOOP;
    
   CLOSE C;
  
END;
/

-- explicit cursor with parameter

DECLARE
 CURSOR PC(DEPTID EMPLOYEES.DEPARTMENT_ID%TYPE DEFAULT 100) IS
   SELECT E.DEPARTMENT_ID DEP,E.LAST_NAME, E.SALARY FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = DEPTID;
   
 V_EMP PC%ROWTYPE;  
    
BEGIN
  OPEN PC(80);
  LOOP
    FETCH PC INTO V_EMP;
    EXIT WHEN PC%NOTFOUND;
    DBMS_OUTPUT.put_line(V_EMP.LAST_NAME||' '||V_EMP.SALARY ||' '|| V_EMP.DEP);
  END LOOP;  
  CLOSE PC;

END;

-- processing data result set select into ??? 

DECLARE
CURSOR C is select e.employee_id, e.last_name from employees e ;
V_EMP C%ROWTYPE;
BEGIN
  null; -- ???
END;

-- processing data result set for loop 

DECLARE
CURSOR C IS SELECT * FROM EMPLOYEES E WHERE  E.DEPARTMENT_ID = 100;
V_EMP C%ROWTYPE;
BEGIN
  FOR E IN C LOOP
      V_EMP := E; 
      DBMS_OUTPUT.put_line('V_EMP '||V_EMP.EMPLOYEE_ID ||' '||E.LAST_NAME ||' '||c%rowcount);
  END LOOP;
END;
-- processing result set via subquires

DECLARE
 CURSOR C IS SELECT E.DEPARTMENT_ID,E.LAST_NAME,E.SALARY,S.ASAL FROM EMPLOYEES E,(SELECT ROUND(AVG(E2.SALARY),2) ASAL, 
                                                                           E2.DEPARTMENT_ID 
                                                                           FROM EMPLOYEES E2
                                                                           GROUP BY E2.DEPARTMENT_ID) S
                                                         WHERE E.DEPARTMENT_ID = S.DEPARTMENT_ID
                                                         AND E.SALARY > S.ASAL;  
 V_EMP C%ROWTYPE;                                                                        
                                                                                                                                  
BEGIN
  FOR E IN C LOOP
      V_EMP := E; 
      DBMS_OUTPUT.put_line('V_EMP '||V_EMP.DEPARTMENT_ID ||' '||V_EMP.LAST_NAME ||' '||V_EMP.SALARY||' '||V_EMP.ASAL);
  END LOOP;
  
   FOR E2 IN C LOOP
      DBMS_OUTPUT.put_line('E2 '||E2.DEPARTMENT_ID ||' '||E2.LAST_NAME ||' '||E2.SALARY||' '||E2.ASAL);
  END LOOP;
END; 
-- FOR LOOP TO ASSIGN CURSOR, TO A COLLECTION

DECLARE
EL TEST_UTILITY.T_EMP_EMAIL := TEST_UTILITY.T_EMP_EMAIL();
CURSOR C IS SELECT EMPLOYEE_ID, EMAIL FROM EMPLOYEES WHERE DEPARTMENT_ID = 100;
VE TEST_UTILITY.EMP_EMAIL;
I NUMBER(5) := 1;
TYPE SL IS TABLE OF EMPLOYEES.SALARY%TYPE;
S SL; 
BEGIN
  --OPEN C;
  DBMS_OUTPUT.put_line(boolean_to_char(EL IS NULL)||EL.COUNT);
--FETCH C BULK COLLECT INTO EL;
--FETCH C BULK COLLECT INTO S; 

FOR E IN C LOOP
 -- VE := E;
  EL.EXTEND;
  EL(I).empid := e.employee_id;
  I := I+1;
END LOOP;   
DBMS_OUTPUT.put_line(EL.COUNT||EL(5).empid);
--CLOSE C;
END;
-- CUROSR VARAIBLES


declare
 vc test_utility.EMC;
 emailList test_utility.T_EMP_EMAIL;
begin
  vc := test_utility.GET_EMAIL_FROM_DEPT2(100);
  fetch vc bulk collect into emailList;
  for i in emailList.first .. emailList.last loop
    dbms_output.put_line(emailList(i).empid||' '||emailList(i).email||' '||boolean_to_char(vc%isopen)||' '|| vc%rowcount);
  end loop;
  
  close vc; 
dbms_output.put_line(boolean_to_char(vc%isopen));
end;


-- CURSOR EXPRESSION

DECLARE
TYPE C IS REF CURSOR;
--TYPE CC IS RECORD (VC C, DNAME DEPARTMENTS.DEPARTMENT_NAME%TYPE );
-- WRONG: the cursor type cannot be in a collection
VC C;
EVC C;
MVC C;
MEVC C;
TYPE DEPTL IS TABLE OF DEPARTMENTS.DEPARTMENT_NAME%TYPE;
DL DEPTL; 

V_DP DEPARTMENTS.DEPARTMENT_NAME%TYPE;
TYPE EINFO IS RECORD ( V_EID EMPLOYEES.EMPLOYEE_ID%TYPE,
                       V_LN EMPLOYEES.LAST_NAME%TYPE,
                       V_SAL EMPLOYEES.SALARY%TYPE                   
                      );
TYPE ELIST IS TABLE OF EINFO;
EL ELIST;
ML ELIST;  
MEL ELIST;

V_M EINFO; 
STR VARCHAR2(100);
MSTR VARCHAR2(100);                     
BEGIN

  OPEN VC FOR SELECT D.DEPARTMENT_NAME,
                     CURSOR(SELECT E.EMPLOYEE_ID, E.LAST_NAME,E.SALARY FROM EMPLOYEES E WHERE E.DEPARTMENT_ID = D.DEPARTMENT_ID) EMPLOYEES,
                     CURSOR(SELECT M.EMPLOYEE_ID , M.LAST_NAME ,M.SALARY,
                                   CURSOR(SELECT ME.EMPLOYEE_ID,ME.LAST_NAME,ME.SALARY 
                                   FROM EMPLOYEES ME 
                                   WHERE ME.MANAGER_ID = M.EMPLOYEE_ID) MANAGED_EMPLOYEE
                            FROM EMPLOYEES M 
                            WHERE M.DEPARTMENT_ID = D.DEPARTMENT_ID
                            AND M.EMPLOYEE_ID IN 
                            (SELECT DISTINCT MANAGER_ID FROM EMPLOYEES E1 
                             WHERE E1.DEPARTMENT_ID = D.DEPARTMENT_ID)) MANAGER
              FROM DEPARTMENTS D;
  
  FETCH VC INTO V_DP,EVC,MVC;
  
  FETCH EVC BULK COLLECT INTO EL;
  
  LOOP
   FETCH MVC INTO V_M.V_EID,V_M.V_LN,V_M.V_SAL,MEVC;
   EXIT WHEN MVC%NOTFOUND;
   MSTR := 'MANAGER: '||V_M.V_EID||' '||V_M.V_LN;
   FETCH MEVC BULK COLLECT INTO MEL;
   FOR I IN MEL.FIRST .. MEL.LAST LOOP
     STR := MSTR||' EMPLOYEE: '||MEL(I).V_EID||' '||MEL(I).V_LN;
     DBMS_OUTPUT.put_line(STR);
     STR := NULL; 
   END LOOP;   
  END LOOP;
  
  
  
/*  FOR I IN EL.FIRST .. EL.LAST LOOP
    DBMS_OUTPUT.put_line('EMPLOYEE: '||EL(I).V_EID||' '||EL(I).V_LN||' '||EL(I).V_SAL);
  END LOOP; 
*/

  /*CLOSE VC;
  CLOSE EVC;
  CLOSE MVC; */
                

END; 
/

-- PIPELINED RETURN TYPE WITH CURSOR

SELECT * FROM TABLE(TEST_UTILITY.GET_MANAGER_INFO(CURSOR(SELECT M.EMPLOYEE_ID , M.LAST_NAME ,M.SALARY,
                                   CURSOR(SELECT ME.EMPLOYEE_ID,ME.LAST_NAME,ME.SALARY 
                                   FROM EMPLOYEES ME 
                                   WHERE ME.MANAGER_ID = M.EMPLOYEE_ID) MANAGED_EMPLOYEE
                            FROM EMPLOYEES M 
                            WHERE M.DEPARTMENT_ID = 80
                            AND M.EMPLOYEE_ID IN 
                            (SELECT DISTINCT MANAGER_ID FROM EMPLOYEES E1 
                             WHERE E1.DEPARTMENT_ID = 80)) ));


SELECT DEPARTMENT_NAME, CURSOR(SELECT E.EMPLOYEE_ID, E.LAST_NAME 
                                               FROM EMPLOYEES E
                                               WHERE E.EMPLOYEE_ID IN (SELECT DISTINCT MANAGER_ID 
                                                                       FROM EMPLOYEES 
                                                                       WHERE DEPARTMENT_ID = D.DEPARTMENT_ID ) ) MANAGER
                FROM DEPARTMENTS D WHERE D.DEPARTMENT_ID = 80; 

