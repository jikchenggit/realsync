create user dsg identified by dsg default tablespace users temporary tablespace temp;

--src dsg privs
grant select any table,select any dictionary,alter system,connect,exp_full_database to dsg;
grant execute on dbms_flashback to dsg;

--tgt dsg privs
grant dba to dsg;
