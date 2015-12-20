#!/bin/ksh

#set db login
DB_USER_PWD="dsg/dsg"

#set check type,default is count(count or minus,all)
CHK_TYPE=count

#set parallel,default is parallel 5
if [ $* -lt $1 ]
then
    P=1
else
    P=$1
fi

#init check
sqlplus -s $DB_USER_PWD <<EOF
exec check_pkg.re_check
exec check_pkg.re_minus
EOF

check()
{
echo "begin recheck count date: "`date`
i=1
while [ $i -le $P ]
do
{
sqlplus -s $DB_USER_PWD <<EOF
exec check_pkg.start_check
EOF
}&
  sleep 1
  let i=i+1
done
wait
echo "end recheck count date: "`date`
}


minus()
{
echo "begin recheck minus date: "`date`
i=1
while [ $i -le $P ]
do
{
sqlplus -s $DB_USER_PWD <<EOF
exec check_pkg.start_minus
EOF
}&
  sleep 1
  let i=i+1
done
wait
echo "end recheck minus date: "`date`
}

if [ "$CHK_TYPE" = "all" ]
then
    check
    minus
fi

if [ "$CHK_TYPE" = "count" ]
then
    check
fi

if [ "$CHK_TYPE" = "minus" ]
then
    minus
fi

