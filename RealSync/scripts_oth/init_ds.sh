#!/bin/ksh
Usage()
{
  echo "    ************************************************************************************"
  echo "    USAGE: init_ds.sh   SERVICE_NAME "
  echo "           SERVICE_NAME : please refer to \${REALSYNC_BASE}/config.srv or all"
  echo "    ************************************************************************************"
  exit
}
if [ $# -lt 1 ]
then
  Usage
fi
sqlplus -s dsg/dsg <<EOF
set timing on
declare
    v_his_flag number :=0;
    v_ct_his_sql varchar2(2000);
begin
    select count(1) into v_his_flag from dba_tables where table_name=upper('$1_check_count_his');
    v_ct_his_sql := 'create table dsg.$1_check_count_his' ||chr(10)||
                  '(arch_id     number,' ||chr(10)||
                  'arch_time   date,' ||chr(10)||
                  'owner       varchar2(30),' ||chr(10)||
                  'table_name  varchar2(30),' ||chr(10)||
                  'bytes       number,' ||chr(10)||
                  'begin_time  date,' ||chr(10)||
                  'end_time    date,' ||chr(10)||
                  'ck_count    number default 0,' ||chr(10)||
                  'flag        number default 0,' ||chr(10)||
                  'err_msg     varchar2(1000),' ||chr(10)||
                  'ck_sql      varchar2(1000),' ||chr(10)||
                  'ck_times    number default 0,' ||chr(10)||
                  'primary key (arch_id,owner,table_name)' ||chr(10)||
                  ')';
    if v_his_flag = 0 
    then
        execute immediate v_ct_his_sql;
    end if;
end;
/

insert into dsg.$1_check_count_his
(arch_id,arch_time,owner,table_name,bytes,begin_time,end_time,ck_count,flag,err_msg,ck_sql,ck_times)
select (select decode(max(arch_id),null,1,max(arch_id)+1) from dsg.$1_check_count_his),
       sysdate,owner,table_name,bytes,begin_time,end_time,ck_count,flag,err_msg,ck_sql,ck_times
from dsg.$1_check_count_tab where flag <> 0;
commit;

drop table dsg.$1_check_count_tab purge;
create table dsg.$1_check_count_tab
(owner       varchar2(30),        
 table_name  varchar2(30),        
 bytes       number,              
 begin_time  date,                
 end_time    date,                
 ck_count    number default 0,    
 flag        number default 0,    
 err_msg     varchar2(1000),      
 ck_sql      varchar2(1000),      
 ck_times    number default 0,    
 primary key (owner,table_name)
); 

insert into dsg.$1_check_count_tab (owner,table_name,bytes)
select owner,segment_name,sum(bytes)/1024/1024/1024 from dba_segments 
where (owner,segment_name) in (select owner,table_name from dsg.$1_sync_tab)
      and segment_type like 'TABLE%'
group by owner,segment_name; 
commit;
EOF
