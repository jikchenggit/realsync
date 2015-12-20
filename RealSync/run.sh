#!/bin/ksh

if [ -z "${REALSYNC_BASE}" ]
then
  cd ../..
  REALSYNC_BASE=`pwd`
fi

if [ -d "$ORACLE_HOME/lib32" ]
then
  export LD_LIBRARY_PATH=$ORACLE_HOME/lib32
  export LIBPATH=$ORACLE_HOME/lib32
  export SHLIB_PATH=$ORACLE_HOME/lib32
else
  export LD_LIBRARY_PATH=$ORACLE_HOME/lib
  export LIBPATH=$ORACLE_HOME/lib
  export SHLIB_PATH=$ORACLE_HOME/lib
fi

Usage()
{
  echo "    ************************************************************************************"
  echo "    USAGE : run.sh SERVICE_NAME"
  echo "            SERVICE_NAME: Please refer to $REALSYNC_BASE/config.srv"
  echo "                                          "
  echo "       SERVICE_NAME LIST:"
  for i in `cat ${REALSYNC_BASE}/config.srv | grep -v "#" | awk '{print $1}'`
  do
  echo "                         $i"
  done 
  echo "    ************************************************************************************"
}

if [ $# -ne 1 -a -z "$RUN_NAME" ]
then
  Usage
  exit
fi

DB_NAME=""
if [ ! -z "$RUN_NAME" ]
then
    DB_NAME=$RUN_NAME
else
    DB_NAME=$1
fi  

SERVICENAME=`grep -w "$DB_NAME" $REALSYNC_BASE/config.srv`
if [ -z "$SERVICENAME" ]
then
  echo "Warning: SERVICE_NAME $DB_NAME not found in ${REALSYNC_BASE}/config.srv."
  echo "SERVICE_NAME LIST:"
  for i in `cat ${REALSYNC_BASE}/config.srv | grep -v "#" | awk '{print $1}'`
  do
  echo "                  $i"
  done
  exit
fi

SYSTEM_ROLE=`grep -w "$DB_NAME" ${REALSYNC_BASE}/config.srv | awk '{print $4}'`

if [ "$SYSTEM_ROLE" = "SRC" ]
then
    echo "Error Operated!"
    echo "Please start run.sh on target host."
    exit
fi

SERVER_IP=`grep SVR_IP ${REALSYNC_BASE}/config/$DB_NAME/config.dsg | awk -F= '{print $2}'`
SERVER_LOGIN=`grep VMANLOGON ${REALSYNC_BASE}/config/$DB_NAME/config.dsg | awk -F= '{print $2}'`

SVR_NAME=$DB_NAME
SVR_PORT=`grep -w "$DB_NAME" ${REALSYNC_BASE}/config.srv | awk '{print $2}'`

DB_USER=`grep TARGET_DB_USER ${REALSYNC_BASE}/config/$DB_NAME/config.dsg | awk -F= '{print $2}'`
DB_PSWD=`grep TARGET_DB_PSWD ${REALSYNC_BASE}/config/$DB_NAME/config.dsg | awk -F= '{print $2}'`

echo "select 'drop '||object_type||' \"'||owner||'\".\"'||object_name||'\" ;' from dba_objects " > $REALSYNC_BASE/config/$SVR_NAME/drop.sql
echo "where owner in" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql
echo "(" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql
echo `cat $REALSYNC_BASE/config/$SVR_NAME/dict.vm |grep -v "#"| grep -v "^$"|awk '{print "'\''"$5"'\'',"}'` |awk '{print substr($0,0,length($0)-1)}' >>$REALSYNC_BASE/config/$SVR_NAME/drop.sql
echo ")" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql
echo "and object_type in ('PROCEDURE','FUNCTION','VIEW','PACKAGE');" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql

echo "" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql

#DROP TEMPORARY TABLE
#echo "select 'drop table '||' \"'||owner||'\".\"'||table_name||'\" ;' from dba_tables " >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql
#echo "where owner in" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql
#echo "(" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql
#echo `cat $REALSYNC_BASE/config/$SVR_NAME/dict.vm |grep -v "#"| grep -v "^$"|awk '{print "'\''"$5"'\'',"}'` |awk '{print substr($0,0,length($0)-1)}' >>$REALSYNC_BASE/config/$SVR_NAME/drop.sql
#echo ")" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql
#echo "and TEMPORARY='Y';" >> $REALSYNC_BASE/config/$SVR_NAME/drop.sql

echo "#!/bin/ksh " > ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "SVR_NAME=${SVR_NAME} " >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "sqlplus /nolog >\${REALSYNC_BASE}/log/\${SVR_NAME}/log.run <<EOF"  >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "conn ${DB_USER}/${DB_PSWD}" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set echo off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set head off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set feedback off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set linesize 150" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set pagesize 0" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set echo off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set head off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set feedback off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set linesize 150" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "set pagesize 0" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "spool \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "@\${REALSYNC_BASE}/config/\${SVR_NAME}/drop.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "spool off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "!cat \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp.sql |grep -v \"SQL>\" > \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp1.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "@\${REALSYNC_BASE}/config/\${SVR_NAME}/tmp1.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "exit" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "EOF" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh
echo "rm -rf \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp*" >> ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh

chmod u+x ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh

${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh


rm -rf ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sql
rm -rf ${REALSYNC_BASE}/config/${SVR_NAME}/drop.sh

if [ "${SVR_NAME}" != "all" ]
then
cd ${REALSYNC_BASE}/bin/${SVR_NAME}
./vman  >> ${REALSYNC_BASE}/log/${SVR_NAME}/log.run <<EOF
connect ${SERVER_IP}:${SVR_PORT}
user ${SERVER_LOGIN}
@${REALSYNC_BASE}/config/${SVR_NAME}/dict.vm
exit
EOF
else
  echo "Please select one of the service names to run."
fi

echo "select 'alter index \"'||owner||'\".\"'||index_name||'\" rebuild;' from dba_indexes " > $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "where owner in" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "(" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo `cat $REALSYNC_BASE/config/$SVR_NAME/dict.vm |grep -v "#"| grep -v "^$"|awk '{print "'\''"$5"'\'',"}'` |awk '{print substr($0,0,length($0)-1)}' >>$REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo ")" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "and status = 'UNUSABLE';" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql

echo "" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql

echo "select 'alter '||object_type||' \"'||owner||'\".\"'||object_name||'\" compile;' from dba_objects " >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "where owner in" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "(" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo `cat $REALSYNC_BASE/config/$SVR_NAME/dict.vm |grep -v "#"| grep -v "^$"|awk '{print "'\''"$5"'\'',"}'` |awk '{print substr($0,0,length($0)-1)}' >>$REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo ")" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "and status = 'INVALID' and object_type in ('PROCEDURE','FUNCTION','VIEW','PACKAGE','TRIGGER');" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql

echo "" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql

echo "select 'alter package \"'||owner||'\".\"'||object_name||'\" compile body;' from dba_objects " >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "where owner in" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "(" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo `cat $REALSYNC_BASE/config/$SVR_NAME/dict.vm |grep -v "#"| grep -v "^$"|awk '{print "'\''"$5"'\'',"}'` |awk '{print substr($0,0,length($0)-1)}' >>$REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo ")" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql
echo "and status = 'INVALID' and object_type in ('PACKAGE BODY');" >> $REALSYNC_BASE/config/$SVR_NAME/compile.sql

echo "#!/bin/ksh " > ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "SVR_NAME=${SVR_NAME} " >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "sqlplus /nolog >>\${REALSYNC_BASE}/log/\${SVR_NAME}/log.run <<EOF"  >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "conn ${DB_USER}/${DB_PSWD}" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set echo off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set head off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set feedback off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set linesize 150" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set pagesize 0" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set echo off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set head off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set feedback off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set linesize 150" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "set pagesize 0" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "spool \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "@\${REALSYNC_BASE}/config/\${SVR_NAME}/compile.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "spool off" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "!cat \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp.sql |grep -v \"SQL>\" > \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp1.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "@\${REALSYNC_BASE}/config/\${SVR_NAME}/tmp1.sql" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "exit" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "EOF" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
echo "rm -rf \${REALSYNC_BASE}/config/\${SVR_NAME}/tmp*" >> ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh

chmod u+x ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh

COUNT=0
while [ $COUNT -lt 5 ]
do
  ${REALSYNC_BASE}/config/${SVR_NAME}/compile.sh
  let COUNT=COUNT+1
done

cat ${REALSYNC_BASE}/config/${SVR_NAME}/dict.vm |grep -v "#" |grep -v "^$" |awk '{print "exec DBMS_STATS.UNLOCK_SCHEMA_STATS('\''"$5"'\'');"}' > ${REALSYNC_BASE}/config/${SVR_NAME}/unlock.sql
sqlplus /nolog >> ${REALSYNC_BASE}/log/${SVR_NAME}/log.run <<EOF
conn ${DB_USER}/${DB_PSWD}
@${REALSYNC_BASE}/config/${SVR_NAME}/unlock.sql
exit
EOF

rm -rf ${REALSYNC_BASE}/config/${SVR_NAME}/unlock.sql

echo "Run.sh is finished."

