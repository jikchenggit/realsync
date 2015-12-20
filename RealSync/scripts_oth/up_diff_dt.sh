#!/bin/ksh
Usage()
{
  echo "    ************************************************************************************"
  echo "    USAGE: up_diff_dt.sh SERVICE_NAME "
  echo "          SERVICE_NAME : please refer to \${REALSYNC_BASE}/config.srv or all"
  echo "    ************************************************************************************"
  exit
}
if [ $# -lt 1 ]
then
  Usage
fi
sqlplus -s dsg/dsg <<EOF
set timing on;
update dsg.$1_check_count_tab set flag=0
 where (owner,table_name) in 
       (select a.owner,a.table_name 
        from dsg.$1_check_count_tab a ,dsg.$1_check_count_tab@dbverify b
        where a.owner=decode(b.map_owner,null,b.owner,b.map_owner) and a.table_name=b.table_name 
          and a.ck_count <> b.ck_count and a.flag <> 0 and b.flag <> 0);
commit;
update dsg.$1_check_count_tab@dbverify set flag=0
 where (owner,table_name) in 
       (select a.owner,a.table_name 
        from dsg.$1_check_count_tab@dbverify a ,dsg.$1_check_count_tab b
        where a.owner=decode(b.map_owner,null,b.owner,b.map_owner) and a.table_name=b.table_name 
          and a.ck_count <> b.ck_count and a.flag <> 0 and b.flag <> 0);
commit;
EOF
