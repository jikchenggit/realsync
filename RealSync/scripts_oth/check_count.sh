#!/bin/ksh
Usage()
{
  echo "    ************************************************************************************"
  echo "    USAGE: check_tab.sh SERVICE_NAME "
  echo "           SERVICE_NAME : please refer to \${REALSYNC_BASE}/config.srv or all"
  echo "    ************************************************************************************"
  exit
}
if [ $# -lt 1 ]
then
  Usage
fi

sqlplus -s dsg/dsg <<EOF
set feedback off
declare
       v_owner     varchar2(30);
       v_tab_name  varchar2(30);
       v_tab_size  number;
       v_ck_count  number;
       v_ck_tab    number;
       v_sql       varchar2(1000);
       v_err_msg   varchar2(1000);
       v_p_flag    char(1) := 'N';    --Y or N,default is N, 
                                      --Y is open parallel select, 
                                      --N is close parallel select
begin
     while true
     loop
        select count(1) into v_ck_tab from dsg.$1_check_count_tab where flag=0;
        if v_ck_tab > 0
        then
          begin
            select count(1) into v_ck_tab from dsg.$1_check_count_tab where flag=0;
     	    select owner,table_name,bytes/1024/1024/1024 into v_owner,v_tab_name,v_tab_size 
     	       from dsg.$1_check_count_tab where flag=0 and rownum<=1;
     	    update dsg.$1_check_count_tab set begin_time=sysdate, flag=2
                   where owner=v_owner and table_name=v_tab_name;
            commit;
            if v_p_flag = 'N' 
            then
                v_sql := 'select count(1) from '||v_owner||'.'||v_tab_name||' dc';
            else
                if v_tab_size < 4
                then
                    v_sql := 'select /*+parallel(dc,4)+*/ count(1) from '||v_owner||'.'||v_tab_name||' dc';
                elsif v_tab_size >=4 and v_tab_size < 8
                then
                    v_sql := 'select /*+parallel(dc,8)+*/ count(1) from '||v_owner||'.'||v_tab_name||' dc';
                elsif v_tab_size >=8 and v_tab_size <= 16
                then
                    v_sql := 'select /*+parallel(dc,12)+*/ count(1) from '||v_owner||'.'||v_tab_name||' dc';
                else
                    v_sql := 'select /*+parallel(dc,16)+*/ count(1) from '||v_owner||'.'||v_tab_name||' dc';
                end if;
            end if;
            update dsg.$1_check_count_tab set ck_sql=v_sql||';'
                   where owner=v_owner and table_name=v_tab_name;
            commit;
            execute immediate v_sql into v_ck_count;
            update dsg.$1_check_count_tab set ck_count=v_ck_count,flag=1,
                   end_time=sysdate , ck_times=ck_times+1
                   where owner=v_owner and table_name=v_tab_name;
            commit;
            exception when others then
               v_err_msg:=sqlerrm;
               update dsg.$1_check_count_tab set flag=3,err_msg=v_err_msg
                      where owner=v_owner and table_name=v_tab_name;
               commit;
          end;
        else
            exit;    
        end if;
     end loop;      
end;
/
EOF
