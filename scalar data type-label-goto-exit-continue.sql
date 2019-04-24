-- plsql data types
-- rowid : represents the unique physical address of a row in a table
select rownum,rowid,e.* from employees e ;
-- not null constrain on varaibles 
declare
 n number not null :=8; -- must assign a value to not null variable otherwise the error occurs
 b constant number :=9; -- the constant has to be initialized 
 c constant number default 10; -- use default to assign values
begin
  dbms_output.put_line(c);
end; 
/

--Scope and Visibility of Identifiers
-- Outer block:
DECLARE
  a CHAR;  -- Scope of a (CHAR) begins
  b REAL;    -- Scope of b begins
BEGIN
  -- Visible: a (CHAR), b
  
  -- First sub-block:
  DECLARE
    a INTEGER;  -- Scope of a (INTEGER) begins
    c REAL;       -- Scope of c begins
  BEGIN
    -- Visible: a (INTEGER), b, c
    NULL;
  END;          -- Scopes of a (INTEGER) and c end

  -- Second sub-block:
  DECLARE
    d REAL;     -- Scope of d begins
  BEGIN
    -- Visible: a (CHAR), b, d
    NULL;
  END;          -- Scope of d ends

-- Visible: a (CHAR), b
END;            -- Scopes of a (CHAR) and b end
/

--Qualifying Redeclared Global Identifier with Block Label
BEGIN
<<outer>>  -- label how to set label??/
DECLARE
  birthdate DATE := TO_DATE('09-AUG-70', 'DD-MON-YY');
BEGIN
  <<inner>>
  DECLARE
    birthdate DATE := TO_DATE('29-SEP-70', 'DD-MON-YY');
  BEGIN
    IF birthdate = outer.birthdate THEN
      DBMS_OUTPUT.PUT_LINE ('Same Birthday');
    ELSE
      DBMS_OUTPUT.PUT_LINE ('Different Birthday');
    END IF;
  END;
END;
END;
/


-- example with GOTO statement
DECLARE
   v_last_name  VARCHAR2(25);
   v_emp_id     NUMBER(6) := 100;
BEGIN
   <<get_name>>
   SELECT last_name INTO v_last_name FROM employees 
          WHERE employee_id = v_emp_id;
      DBMS_OUTPUT.PUT_LINE (v_last_name);
      v_emp_id := v_emp_id + 5;
      IF v_emp_id < 120 THEN
        GOTO get_name;  -- branch to enclosing block
      END IF;
END;
/
-- USER DEFINED SUBTYPE

declare
  subtype sal is number(8,2);
  s sal := 80;
  subtype eid is PLS_INTEGER range 1..100; -- the only tyoe can be used as based type for range is pls_integer
  e eid :=5;
begin 
  dbms_output.put_line(e);
end;
/


-- EXIT statement: exits the current iteration of the loop unconditionally and transfer the control to the end of loop 
-- exit when : add a condition to exit the loop
-- continue statement: exits the current iteration of the loop unconditionally and transfer the control to the next iteration of the current loop

DECLARE
  x NUMBER := 0;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE ('Inside loop:  x = ' || TO_CHAR(x));
    x := x + 1;
    IF x > 3 THEN
      EXIT;
    END IF;
  END LOOP;
  -- After EXIT, control resumes here
  DBMS_OUTPUT.PUT_LINE(' After loop:  x = ' || TO_CHAR(x));
END;
/
