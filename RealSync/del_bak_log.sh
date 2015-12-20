#!/bin/ksh

REALSYNC_BASE=/templv/yqing/test10/RealSync
LOG_PATH=/templv/yqing/test10/RealSync/backuplog
LOG_NODE=/templv
THREADS=1
SPACE_WARING=80

T_CNT=1

#DELETE BACKUP LOG
cd $LOG_PATH
echo "Begin remove time "`date +%Y-%m-%d:%H:%M:%S` >> $LOG_PATH/log.delete
while [ $T_CNT -le $THREADS ]
do
  S_CNT=0
  AGENT_MIN_SEQ=0
  for i in `cat $REALSYNC_BASE/xldr/*/cfg.finishseq |grep -w " $T_CNT " |awk '{print $2}'`
  do
    if [ ${S_CNT} -eq 0 ]
    then
        let AGENT_MIN_SEQ=i
    else
        if [ ${i} -le ${AGENT_MIN_SEQ} ]
        then
            let AGENT_MIN_SEQ=i
        fi 
    fi 
    let S_CNT=S_CNT+1
  done
  echo "T${T_CNT} AGENT MIN SEQ $AGENT_MIN_SEQ" >> $LOG_PATH/log.delete
  MIN_SEQ=`ls -ltr |grep ".dbf" |grep ${T_CNT}"_" |awk '{print $9}' |sort |head -1|awk -F_ '{print $2}' |awk -F. '{print $1}'`

  if [ "$MIN_SEQ" = "" ]
  then
      echo "T${T_CNT} BAK MIN SEQ IS NULL" >> $LOG_PATH/log.delete
      let MIN_SEQ=AGENT_MIN_SEQ+1
  else
      echo "T${T_CNT} BAK MIN SEQ $MIN_SEQ" >> $LOG_PATH/log.delete
  fi
  
  if [ $MIN_SEQ -le $AGENT_MIN_SEQ ]
  then
      echo "remove thread ${T_CNT} backup logfile $MIN_SEQ to $AGENT_MIN_SEQ" >> $LOG_PATH/log.delete
  else
      echo "thread ${T_CNT} no backup logfile need to remove!" >> $LOG_PATH/log.delete
  fi
 
  while [ $MIN_SEQ -le $AGENT_MIN_SEQ ]
  do
    rm -rf $LOG_PATH/${T_CNT}_${MIN_SEQ}.dbf
    echo "remove backup logfile $LOG_PATH/${T_CNT}_${MIN_SEQ}.dbf" >> $LOG_PATH/log.delete
    let MIN_SEQ=MIN_SEQ+1
  done
  let T_CNT=T_CNT+1
done

echo "End remove time "`date +%Y-%m-%d:%H:%M:%S` >> $LOG_PATH/log.delete

echo "" >> $LOG_PATH/log.delete


#CHECK LOG PATH SPACE

echo "BACKUP LOG PATH SPACE USERD" >> $LOG_PATH/log.delete

HOSTTYPE=`uname`
SPACE_USED=0

if [ "$HOSTTYPE" = "HP-UX" ]
then
    bdf |head -1 >> $LOG_PATH/log.delete
    bdf |grep "$LOG_NODE" >> $LOG_PATH/log.delete
    SPACE_USED=`bdf |grep "$LOG_NODE" |awk '{print $5}' |awk -F% '{print $1}'`
fi

if [ "$HOSTTYPE" = "AIX" ]
then
    df -k |head -1 >> $LOG_PATH/log.delete
    df -k |grep "$LOG_NODE" >> $LOG_PATH/log.delete
    SPACE_USED=`df -k |grep "$LOG_NODE" |awk '{print $4}' |awk -F% '{print $1}'`
fi

if [ "$HOSTTYPE" = "Linux" ]
then
    df -k |head -1 >> $LOG_PATH/log.delete
    df -k |grep "$LOG_NODE" >> $LOG_PATH/log.delete
    SPACE_USED=`df -k |grep "$LOG_NODE" |awk '{print $5}' |awk -F% '{print $1}'`
fi

if [ $SPACE_USED -ge $SPACE_WARING ]
then
    echo "Space Warning,auto clear space:" >> $LOG_PATH/log.delete
    cd $LOG_PATH
    ls -ltr |grep ".dbf" |head -5 |awk '{print "rm -rf "$9}' >> $LOG_PATH/log.delete
    ls -ltr |grep ".dbf" |head -5 |awk '{print "rm -rf "$9}' |sh
fi

echo "" >> $LOG_PATH/log.delete
