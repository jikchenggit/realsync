set linesize 150
set pagesize 100
col column_name format a30
col table_name format a30
col index_name format a30
col owner format a30
select a.owner,a.table_name,a.index_name,COLUMN_NAME from dba_indexes@dbverify a,dba_ind_columns@dbverify b
where a.owner=b.table_owner and a.table_name=b.table_name and a.index_name=b.index_name and COLUMN_NAME not like 'SYS%' and a.index_name not like 'SYS%'
and (  a.owner in (select username from dsg.db_users@dbverify))
minus
select a.owner,a.table_name,a.index_name,COLUMN_NAME from dba_indexes a,dba_ind_columns b
where a.owner=b.table_owner and a.table_name=b.table_name and a.index_name=b.index_name;

select grantee,privilege from dba_sys_privs@dbverify where grantee in 
(select username from dsg.db_users@dbverify) 
or grantee in (select username from dsg.db_users@dbverify)
minus
select grantee,privilege from dba_sys_privs;

select grantee,granted_role from dba_role_privs@dbverify where grantee in 
(select username from dsg.db_users@dbverify) 
or grantee in (select username from dsg.db_users@dbverify)
minus
select grantee,granted_role from dba_role_privs;

select role from dba_roles@dbverify
minus
select role from dba_roles;


set line 200
col name for a30
col text for a40
select c.owner,c.name,c.type,count(*) from
(select a.owner,a.name,a.type,a.line from dba_source@dbverify a,dba_source b
where ( a.owner in (select username from dsg.db_users@dbverify))
        and a.line>1  and a.owner=b.owner and a.name=b.name and a.type=b.type and a.line=b.line 
        and replace(a.text,' ')<>replace(b.text,' ')  order by a.owner,a.name,a.line) c
group by c.owner,c.name,c.type;

set linesize 150
set pagesize 100
col owner format a30
col object_type format a30
select a.owner,a.object_type,a.cnt src_cnt,decode(b.cnt,null,0,b.cnt) tgt_cnt from
(select owner,object_type,count(*) cnt from dba_objects@dbverify 
where object_name not like 'SYS%' and object_name not like 'BIN$%'
group by owner,object_type) a
left join
(select owner,object_type,count(*) cnt from dba_objects 
where object_name not like 'SYS%' and object_name not like 'BIN$%'
group by owner,object_type) b
on a.owner=b.owner and a.object_type=b.object_type
where ( a.owner in (select username from dsg.db_users@dbverify))
       and a.cnt<>decode(b.cnt,null,0,b.cnt) order by 1,2;

set linesize 150
set pagesize 100
col owner format a30
col object_type format a30
col constraint_type format a20
select a.owner,a.constraint_type,a.cnt src_cnt,decode(b.cnt,null,0,b.cnt) tgt_cnt from
(select owner,constraint_type,count(*) cnt from dba_constraints@dbverify where constraint_name not like 'BIN$%' 
group by owner,constraint_type) a
left join
(select owner,constraint_type,count(*) cnt from dba_constraints group by owner,constraint_type) b
on a.owner=b.owner and a.constraint_type=b.constraint_type
where ( a.owner in (select username from dsg.db_users@dbverify))
        and a.constraint_type in ('P','R') and a.cnt<>decode(b.cnt,null,0,b.cnt) ;

set linesize 150
set pagesize 100
col owner format a30
col object_type format a30
col object_name format a30
col src_stat format a10
col tgt_stat format a10
select a.owner,a.object_type,a.object_name,a.status src_stat,b.status tgt_stat from
(select owner,object_type,object_name,status from dba_objects@dbverify) a
left join
(select owner,object_type,object_name,status from dba_objects) b
on a.owner=b.owner and a.object_type=b.object_type and a.object_name=b.object_name
where ( a.owner in (select username from dsg.db_users@dbverify))
        and a.status<>b.status and b.status='INVALID';

set linesize 150
set pagesize 100
col owner format a30
col table_name format a30
col constraint_name format a30
col constraint_type format a5
col src_cons_stat format a10
col tgt_cons_stat format a10
select a.owner,a.table_name,a.constraint_name,a.constraint_type,a.status src_cons_stat,b.status tgt_cons_stat from
(select owner,table_name,constraint_name,constraint_type,status from dba_constraints@dbverify) a
left join
(select owner,table_name,constraint_name,constraint_type,status from dba_constraints) b
on a.owner=b.owner and a.table_name=b.table_name and a.constraint_type=b.constraint_type
where ( a.owner in (select username from dsg.db_users@dbverify))
        and a.status<>b.status and b.status='INVALID';

set linesize 150
set pagesize 100
col sequence_owner format a30
col sequence_name format a30
col src_last_number format 9999999999999999999999999999
col tgt_last_number format 9999999999999999999999999999
select a.sequence_owner,a.sequence_name,a.last_number src_last_number,b.last_number tgt_last_number  from
(select SEQUENCE_OWNER,SEQUENCE_NAME,LAST_NUMBER from dba_sequences@dbverify) a
left join
(select SEQUENCE_OWNER,SEQUENCE_NAME,LAST_NUMBER from dba_sequences) b
on a.sequence_owner=b.sequence_owner and a.sequence_name=b.sequence_name
where ( a.sequence_owner in (select username from dsg.db_users@dbverify)) and a.last_number > b.last_number;


set linesize 150
set pagesize 100
col owner format a30
col table_name format a30
select a.owner,a.table_name,a.cnt src_cnt,decode(b.cnt,null,0,b.cnt) tgt_cnt from
(select owner,table_name,max(column_id) cnt from dba_tab_columns@dbverify group by owner,table_name ) a
left join
(select owner,table_name,max(column_id) cnt from dba_tab_columns group by owner,table_name ) b
on a.owner=b.owner and a.table_name=b.table_name and a.table_name not like 'BIN$%'
where ( a.owner in (select username from dsg.db_users@dbverify)) and a.table_name not like 'BIN$%'
        and a.cnt<>decode(b.cnt,null,0,b.cnt) ;

