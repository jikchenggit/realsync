#!/bin/ksh

#set db login
DB_USER_PWD="dsg/dsg"

sqlplus -s $DB_USER_PWD <<EOF
spool check_obj.log
@check_obj.sql
spool off
EOF
