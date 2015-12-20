select 'create user '||username||' identified by values '''||password||''' default tablespace '||default_tablespace||' temporary tablespace '||temporary_tablespace||';' from dba_users where username='&USERNAME';

select 'grant '||granted_role||' to '||grantee||case when ADMIN_OPTION='NO' then ';' when ADMIN_OPTION='YES' then ' with admin option;' end 
  from dba_role_privs where grantee not like '%SYS%' and grantee not in('DSG');
  
select 'grant '||privilege||' to '||grantee||case when ADMIN_OPTION='NO' then ';' when ADMIN_OPTION='YES' then ' with admin option;' end 
  from dba_sys_privs where grantee not like '%SYS%' and grantee not in('DSG');

select 'grant '||PRIVILEGE||' on '||OWNER||'.'||TABLE_NAME||' to '||GRANTEE||case when GRANTABLE='NO' then ';' when GRANTABLE='YES' then ' with grant option;' end 
  from DBA_TAB_PRIVS where grantee not like '%SYS%' and grantee not in('DSG');
