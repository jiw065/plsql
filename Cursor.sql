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


