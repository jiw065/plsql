create table TEST_POLICY  
(  
  POLICY_CODE VARCHAR2(20),  
  POLICY_TYPE CHAR(1)  
);


CREATE OR REPLACE Procedure P_Insert_Policy(I_Policy_code varchar2,
                            I_Policy_type char) as
  cnt number :=0;
  begin
      select count(1) into cnt from Test_Policy;
      Dbms_Output.put_line('NESTED -- records of the test_policy is '|| cnt);

      Insert into Test_Policy values(I_Policy_code, I_Policy_type);
      commit;--commit in nested transaction
  end P_Insert_Policy;

  CREATE OR REPLACE Procedure P_Insert_Policy2(I_Policy_code varchar2,
                            I_Policy_type char) as
  cnt number :=0;
  pragma autonomous_transaction;
  begin
      select count(1) into cnt from Test_Policy;
      Dbms_Output.put_line('NESTED -- records of the test_policy is '|| cnt);

      Insert into Test_Policy values(I_Policy_code, I_Policy_type);
      commit;--commit in nested transaction
  end P_Insert_Policy2;
  
--call procedure used in nested transaction  
  create or replace PROCEDURE TEST_PL_SQL_ENTRY AS  
  strSql varchar2(500);  
  cnt number := 0;  
  BEGIN  
     delete from test_policy;  
     commit;  
     insert into test_policy values('2010042101', '1');  
     select count(1) into cnt from Test_Policy;  
     Dbms_Output.put_line('records of the test_policy is '|| cnt);  
     --call nested transaction  
     P_Insert_Policy('2010042102', '2');  
     rollback;--rollback data for all transactions  
     commit;--master transaction commit  
     select count(1) into cnt from Test_Policy;  
     Dbms_Output.put_line('records of the test_policy is '|| cnt);  
     rollback;  
       
     select count(1) into cnt from Test_Policy;  
     Dbms_Output.put_line('records of the test_policy is '|| cnt); 
     
     dbms_output.put_line('test AT ------------------------------------- TEST AT');
     --- test AT
     delete from test_policy;  
     commit;  
     insert into test_policy values('2010042101', '1');  
     select count(1) into cnt from Test_Policy;  
     Dbms_Output.put_line('records of the test_policy is '|| cnt);  
     --call nested transaction  
     P_Insert_Policy2('2010042102', '2');  
     rollback;--rollback data for all transactions  
     commit;--master transaction commit  
     select count(1) into cnt from Test_Policy;  
     Dbms_Output.put_line('records of the test_policy is '|| cnt);  
     rollback;  
       
     select count(1) into cnt from Test_Policy;  
     Dbms_Output.put_line('records of the test_policy is '|| cnt);   
       
END TEST_PL_SQL_ENTRY;  

begin
  TEST_PL_SQL_ENTRY;

end; 
