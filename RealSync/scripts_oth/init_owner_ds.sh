#!/bin/ksh
Usage()
{
  echo "    ************************************************************************************"
  echo "    USAGE: init_owner.sh  SERVICE_NAME "
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
    v_flag number :=0;
    v_ct_sql varchar2(2000);
begin
    select count(1) into v_flag from dba_tables where table_name=upper('$1_sync_tab');
    v_ct_sql := 'create table dsg.$1_sync_tab' ||chr(10)||
                '( owner      varchar2(30),' ||chr(10)||
                '  table_name varchar2(30),' ||chr(10)||
                '  map_owner  varchar2(30),' ||chr(10)||
                '  real_flag  number default 1,' ||chr(10)||
                '  full_flag  number default 1,' ||chr(10)||
                '  bytes      number,' ||chr(10)||
                '  init_date  date,' ||chr(10)||
                '  primary key (owner,table_name)' ||chr(10)||
                ')';
    if v_flag = 0
    then
        execute immediate v_ct_sql;
    end if;
end;
/

truncate table dsg.$1_sync_tab;

insert into dsg.$1_sync_tab (owner,table_name)
select owner,table_name from dba_tables
where owner in ('DSG') 
      and table_name not like 'BIN$%' and temporary='N';
commit;

update dsg.$1_sync_tab a
set a.bytes=(select sum(bytes) from dba_segments where owner=a.owner and segment_name=a.table_name),
    init_date=sysdate;
commit;

--user mapping
--update dsg.$1_sync_tab
--set map_owenr='' where owner='DSG'
EOF
