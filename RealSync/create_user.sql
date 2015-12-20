--SRC USER
create user dsg identified by dsg default tablespace users temporary tablespace temp;
grant select any table,select any dictionary,alter system ,exp_full_database,connect to dsg;

--TGT USER
create user dsg identified by dsg default tablespace users temporary tablespace temp;
grant dba to dsg;
