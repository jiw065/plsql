-- forward declaration (???)
DECLARE
  -- Declare proc1 (forward declaration):
  PROCEDURE proc1(number1 NUMBER);

  -- Declare and define proc2:
  PROCEDURE proc2(number2 NUMBER) IS
  BEGIN
    proc1(number2);
  END;

  -- Define proc 1:
  PROCEDURE proc1(number1 NUMBER) IS
  BEGIN
    proc2 (number1);
  END;

BEGIN
  NULL;
END;
/

--Aliasing from Same Actual Parameter for Multiple Formal Parameters


DECLARE
  n NUMBER := 10;

  PROCEDURE p (
    n1 IN NUMBER,
    n2 IN OUT NUMBER,
    n3 IN OUT NOCOPY NUMBER
  ) IS
  BEGIN
    n2 := 20;  -- actual parameter is 20 only after procedure succeeds
    DBMS_OUTPUT.put_line(n1);  -- actual parameter value is still 10
    n3 := 30;  -- might change actual parameter immediately
    DBMS_OUTPUT.put_line(n1);  -- actual parameter value is either 10 or 30
  END;

BEGIN
  p(n, n, n);
  DBMS_OUTPUT.put_line(n);
END;
/

--Aliasing from Cursor Variable Subprogram Parameters
DECLARE
  TYPE EmpCurTyp IS REF CURSOR;
  c1 EmpCurTyp;
  c2 EmpCurTyp;

  PROCEDURE get_emp_data (
    emp_cv1 IN OUT EmpCurTyp,
    emp_cv2 IN OUT EmpCurTyp
  )
  IS
    emp_rec employees%ROWTYPE;
  BEGIN
    OPEN emp_cv1 FOR SELECT * FROM employees;
    emp_cv2 := emp_cv1;  -- now both variables refer to same location
    FETCH emp_cv1 INTO emp_rec;  -- fetches first row of employees
    FETCH emp_cv1 INTO emp_rec;  -- fetches second row of employees
    FETCH emp_cv2 INTO emp_rec;  -- fetches third row of employees
    CLOSE emp_cv1;  -- closes both variables
    FETCH emp_cv2 INTO emp_rec; -- causes error when get_emp_data is invoked
  END;
BEGIN
  get_emp_data(c1, c2);
END;
/

-- test varchar2 passed in  number NO cannot do this

declare
c number(4,3) := 4.32;

procedure t(p1 number)
is
begin
  dbms_output.put_line(p1);
end t;

begin
  t(c);
  t(3);

end;
/

-- Recursive Function Returns n Factorial (n!)

DECLARE
N NUMBER(9);
FUNCTION Factorial(pn number)
RETURN NUMBER
IS
BEGIN
  IF PN = 1 THEN
    RETURN 1;
  END IF;    

 RETURN PN*Factorial(PN-1);
END;

BEGIN
  N := Factorial(5);
  DBMS_OUTPUT.put_line(N);

END;
/

-- nth Fibonacci number
DECLARE
N NUMBER(10);
FUNCTION FIB(PN NUMBER)
  RETURN NUMBER
IS  
BEGIN
  IF PN = 1 THEN
    RETURN 0;
  ELSIF PN = 2 THEN
    RETURN 1;  
  END IF;
  
  RETURN FIB(PN-1)+FIB(PN-2);
END FIB;  
  
BEGIN
  N := FIB(10);
  DBMS_OUTPUT.put_line(N);

END;
/


-- result cahce

-- with recusive function

DECLARE
N NUMBER(10);

BEGIN
  N := fibonacci(40);
  DBMS_OUTPUT.put_line(N);
  DBMS_OUTPUT.put_line(fibonacci(40));

END;
/
-- first run above function: 

CREATE OR REPLACE FUNCTION fibonacci (n NUMBER)
   RETURN NUMBER RESULT_CACHE IS
BEGIN
  IF (n =0) OR (n =1) THEN
    RETURN 1;
  ELSE
    RETURN fibonacci(n - 1) + fibonacci(n - 2);
  END IF;
END;
/



explain plan for select /*+ result_cache +*/    department_id, avg(salary)     from employees    group by department_id;
SELECT plan_table_output FROM table(dbms_xplan.display());
 
-- TEST FORMAL PARAMETER MODE

DECLARE

 A1 NUMBER(3) := 10;
 A2 NUMBER(3) := 20;
 A3 NUMBER(3) := 30;
 
 V_N NUMBER(3); 
 
FUNCTION TEST_MODE(P1 IN NUMBER, P2 OUT NUMBER, P3 IN OUT NUMBER)
 RETURN NUMBER
 IS
 BEGIN
   DBMS_OUTPUT.put_line('P1= '||P1);
   DBMS_OUTPUT.put_line('P2= '||P2);
   DBMS_OUTPUT.put_line('P3= '||P3);
   
   --P1:= 100; CANNOT UPDATE IN MODE PARAMETER
   P2:= 200;
   P3:=300; 
   
   RETURN 0;
 
 END TEST_MODE;
 

BEGIN
  V_N := TEST_MODE(A1,A2,A3);
   DBMS_OUTPUT.put_line('A1= '||A1);
   DBMS_OUTPUT.put_line('A2= '||A2);
   DBMS_OUTPUT.put_line('A3= '||A3);

END;
/
