#!/bin/ksh

#set db login
DB_USER_PWD="dsg/dsg"

sqlplus -s $DB_USER_PWD <<EOF
exec check_pkg.stop_check
exec check_pkg.stop_minus
EOF

