sqlplus -s dsg/dsg <<EOF
create table dsg.object_name_tab
(owner       varchar2(30),
 object_name varchar2(130),
 object_type varchar2(20),
 primary key (owner,object_name,object_type));

insert into dsg.object_name_tab (owner,object_name,object_type)
select owner,table_name,'TABLE' from 
(
select owner,table_name from dba_tables@dbverify where owner in ('DSG') 
                  and table_name not like 'BIN$%' and temporary = 'N' 
minus
select owner,table_name from dba_tables where owner in ('DSG')
);
commit;

set pagesize 0
set long 1000000
set linesize 300
col sql for a300
select dbms_metadata.get_ddl(object_type,object_name,owner) from dsg.object_name_tab;
exit;
EOF
