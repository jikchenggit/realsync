sqlplus -s dsg/dsg >log.tmp <<EOF
set serveroutput on
drop table dsg.object_name_tab purge;
create table dsg.object_name_tab
(owner       varchar2(30),
 object_name varchar2(130),
 object_type varchar2(20),
 flag        number default 0,
 degree      number default 0,
 get_sql     varchar2(1000),
 sql_text    clob,
 err_msg     varchar2(1000),
 primary key (owner,object_name,object_type));
drop table dsg.temp_sql purge;
create global temporary table dsg.temp_sql 
(owner varchar2(30),object_name varchar2(130),object_type varchar2(20),sql_text clob);
declare
       tab_flag    char(1):='N'; --Y or N
       ind_flag    char(1):='Y'; --Y or N
       pk_flag     char(1):='N'; --Y or N
       fk_flag     char(1):='N'; --Y or N
       proc_flag   char(1):='N'; --Y or N
       func_flag   char(1):='N'; --Y or N
       view_flag   char(1):='N'; --Y or N
       trig_flag   char(1):='N'; --Y or N
       db_link_flag   char(1):='N'; --Y or N
       syno_flag   char(1):='N'; --Y or N
       get_owner   varchar2(30):='DSG';
       ind_degree  number:=3;
       pk_degree   number:=3;
begin
  dbms_output.put_line(get_owner);
  if tab_flag = 'Y' 
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,table_name,'TABLE' from 
      (
      select owner,table_name from dba_tables@dbverify where owner in (get_owner) 
                    and table_name not like 'BIN$%' and temporary = 'N' 
      minus
      select owner,table_name from dba_tables where owner in (get_owner)
      );
      commit;
  end if;
  if ind_flag = 'Y'
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,index_name,'INDEX' from
      (
      select owner,index_name from dba_indexes@dbverify where owner in (get_owner)
                        and index_name not like 'BIN$%'  and index_type !='LOB'
      minus
      select owner,index_name from dba_indexes where owner in (get_owner)
      );
      commit;
      update dsg.object_name_tab set degree=ind_degree
      where owner in (get_owner) and object_type in ('INDEX');
      commit;
  end if;
  if pk_flag = 'Y'
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,constraint_name,'CONSTRAINT' from
      (
       select owner,constraint_name from dba_constraints@dbverify where owner in (get_owner)
                        and constraint_name not like 'BIN$%' and constraint_type='P'
       minus
       select owner,constraint_name from dba_constraints where owner in (get_owner)
      );
      commit;
      update dsg.object_name_tab set degree=pk_degree
      where owner in (get_owner) and object_type in ('CONSTRAINT');
      commit;
  end if;
  if fk_flag = 'Y'
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,constraint_name,'REF_CONSTRAINT' from
      (
       select owner,constraint_name from dba_constraints@dbverify where owner in (get_owner)
                        and constraint_name not like 'BIN$%' and constraint_type='R'
       minus
       select owner,constraint_name from dba_constraints where owner in (get_owner)
      );
      commit;
  end if;
  if proc_flag = 'Y'
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,object_name,object_type from
      (
       select owner,object_name,object_type from dba_objects@dbverify
        where owner in (get_owner) and object_type in ('PROCEDURE')
       minus
       select owner,object_name,object_type from dba_objects where owner in (get_owner)
      );
      commit;
  end if;
  if func_flag = 'Y'
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,object_name,object_type from
      (
       select owner,object_name,object_type from dba_objects@dbverify
        where owner in (get_owner) and object_type in ('FUNCTION') 
       minus
       select owner,object_name,object_type from dba_objects where owner in (get_owner)
      );
      commit;
  end if;
  if view_flag = 'Y'
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,view_name,'VIEW' from
      (
       select owner,view_name from dba_views@dbverify
        where owner in (get_owner)
       minus
       select owner,view_name from dba_views where owner in (get_owner)
      );
      commit;
  end if;
  if trig_flag = 'Y'
  then
      insert into dsg.object_name_tab (owner,object_name,object_type)
      select owner,trigger_name,'TRIGGER' from
      (
       select owner,trigger_name from dba_triggers@dbverify                
        where owner in (get_owner)
       minus
       select owner,trigger_name from dba_triggers where owner in (get_owner) 
      );
      commit;
  end if;
end;
/
set pagesize 0
set long 1000000
set linesize 300
col sql_text for a300
set feedback off
set serveroutput on size 1000000
declare
      v_sql   varchar2(200);
      v_owner varchar2(30);
      v_object_name varchar2(130);
      v_object_type varchar2(20);
      v_degree  number;
      v_err_msg varchar2(1000);
      v_count number;
begin
     select count(1) into v_count from dsg.object_name_tab where flag=0;
     while true
     loop 
         select count(1) into v_count from dsg.object_name_tab where flag=0;
             if v_count > 0
             then
                 select owner,object_name,object_type,degree into v_owner,v_object_name,v_object_type,v_degree
                 from dsg.object_name_tab where flag=0 and rownum<=1;
                 if v_degree > 0
                 then
                   v_sql := 'select dbms_lob.substr@dbverify('||
                            'dbms_metadata.get_ddl@dbverify('''||v_object_type||''','''||
                             v_object_name||''','''||v_owner||'''))||'' parallel '||v_degree||' nologging ''||chr(10)||''/'' sql '||'from dual@dbverify';
                   insert into dsg.temp_sql@dbverify select v_owner,v_object_name,v_object_type,
                          dbms_metadata.get_ddl@dbverify(v_object_type,v_object_name,v_owner) ||' parallel '||v_degree||' nologging '||chr(10)||'/' from dual@dbverify;
                   insert into dsg.temp_sql select * from dsg.temp_sql@dbverify;
                   update dsg.object_name_tab a set get_sql=v_sql||';',a.flag=4,a.sql_text=
                         (select sql_text from dsg.temp_sql where owner=a.owner 
                          and object_name=a.object_name and object_type = a.object_type)
                   where owner=v_owner and object_name=v_object_name and object_type=v_object_type;
                   commit; 
                 else
                   v_sql := 'select dbms_lob.substr@dbverify('||
                            'dbms_metadata.get_ddl@dbverify('''||v_object_type||''','''||
                             v_object_name||''','''||v_owner||'''))||''/'' sql '||'from dual@dbverify';
                   insert into dsg.temp_sql@dbverify select v_owner,v_object_name,v_object_type,
                          dbms_metadata.get_ddl@dbverify(v_object_type,v_object_name,v_owner) ||'/' from dual@dbverify;
                   insert into dsg.temp_sql select * from dsg.temp_sql@dbverify;
                   update dsg.object_name_tab a set get_sql=v_sql||';',a.flag=4,a.sql_text=
                         (select sql_text from dsg.temp_sql where owner=a.owner
                          and object_name=a.object_name and object_type = a.object_type)
                   where owner=v_owner and object_name=v_object_name and object_type=v_object_type;
                   commit;
                 end if;
             else
                 exit;
             end if;
     end loop; 
end;
/
EOF

sqlplus -s dsg/dsg >t.sql <<EOF
set pagesize 0
set long 1000000
set linesize 300
col sql for a300
set feedback off
select sql_text from dsg.object_name_tab;
select 'alter '||object_type||' "'||owner||'"."'||object_name||'" parallel 1;'
from dsg.object_name_tab where object_type='INDEX' and  degree !=0;
exit;
EOF

P_EXEC=3
V_CNT=1
while [ $V_CNT -le $P_EXEC ]
do
  echo "sqlplus -s dsg/dsg >log.exec$V_CNT <<EOF" >exec$V_CNT.sh
  echo "set timing on" >>exec$V_CNT.sh
  echo "alter session set sort_area_size=10485760;" >>exec$V_CNT.sh
  echo "@exec$V_CNT.sql" >>exec$V_CNT.sh
  echo "exit;" >> exec$V_CNT.sh
  echo "EOF" >>exec$V_CNT.sh
  > exec$V_CNT.sql
  let V_CNT=V_CNT+1
done

while true
do
  O_CNT=`grep "/" t.sql |wc -l`
  V_CNT=1
  if [  $O_CNT -gt 0 ]
  then
     while [ $V_CNT -le $P_EXEC ]
     do
       O_CNT=`grep "/" t.sql |wc -l`
       if [  $O_CNT -eq 0 ]
       then
           break
       fi
       R_CNT=`sed -n '/\//=' t.sql |head -1` 
       sed -n '1,'$R_CNT'p' t.sql >> exec$V_CNT.sql
       sed  '1,'$R_CNT'd' t.sql >tt.sql
       mv tt.sql t.sql
       let V_CNT=V_CNT+1
     done
  else
     break
  fi
done

V_CNT=1
> exec.sh
while [ $V_CNT -le $P_EXEC ]
do
  cat t.sql >> exec$V_CNT.sql
  echo "nohup ./exec$V_CNT.sh &" >>exec.sh
  let V_CNT=V_CNT+1
done
