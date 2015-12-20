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
echo "begin init check date: "`date`
sqlplus -s $DB_USER_PWD <<EOF
exec check_pkg.init_check
EOF
echo "end init check date: "`date`

check()
{
echo "begin check count date: "`date`
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
echo "end check count date: "`date`
}


minus()
{
echo "begin check minus date: "`date`
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
echo "end check minus date: "`date`
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

