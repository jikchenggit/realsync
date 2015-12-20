#!/bin/ksh
Usage()
{
  echo "    ************************************************************************************"
  echo "    USAGE:  mon_check.sh SERVICE_NAME "
  echo "          SERVICE_NAME : please refer to \${REALSYNC_BASE}/config.srv or all"
  echo "    ************************************************************************************"
  exit
}
if [ $# -lt 1 ]
then
  Usage
fi
while true
do
sqlplus -s dsg/dsg <<EOF
set feedback off;
alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS';
select round(sum(bytes),3) TABLE_SIZE_GB,count(1) TABLE_COUNT,flag 
from dsg.$1_check_count_tab 
group by flag order by flag asc;
select min(begin_time) min_begin_time,max(end_time) max_end_time,round((max(end_time)-min(begin_time))*24*60,2) over_time_min
from dsg.$1_check_count_tab;
exit;
EOF
PARA_CNT=`ps -ef |grep check_count|grep -v grep |wc -l`
echo "parallel check number:"$PARA_CNT
sleep 3
clear
done
