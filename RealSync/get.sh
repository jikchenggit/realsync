#!/bin/ksh
#SYSTEM=AIX5.2
#SYSTEM=$1
#VERSION=6.2.1.3.qa
#VERSION=6.2.1.4.qa


get_single()
{
ftp -i -n 192.168.1.174  <<EOF
user release dsg@release
prompt off
bin
cd RealSync/$SYSTEM/$R_VER
ls -al
lcd RealSync/bin/$OS
prompt off
bin
mget dbpsd vman xfview x_* *.$O_VER.*
EOF
ls -al RealSync/bin/$OS

echo ""
echo "The $R_VER RealSync SoftWare for $OS and $ORACLE_VER was get finished!"
}

get_6214_qa()
{
ftp -i -n 192.168.1.174  <<EOF
user release dsg@release
prompt off
bin
cd RealSync/$SYSTEM/$ORA_VER
ls -ltr
lcd RealSync/bin/$OS
prompt off
bin
mls -ltr 
release.txt

exit
EOF

#R_VER=`sort RealSync/bin/$OS/release.txt |tail -1`
R_VER=`cat RealSync/bin/$OS/release.txt |grep oracle |awk '{print $9}' |tail -1`
echo $R_VER

ftp -i -n 192.168.1.174  <<EOF
user release dsg@release
prompt off
bin
cd RealSync/$SYSTEM/$ORA_VER
lcd RealSync/bin/$OS
prompt off
bin
mget $R_VER
EOF

mkdir -p RealSync/bin/$OS/$O_VER
mv RealSync/bin/$OS/$R_VER RealSync/bin/$OS/$O_VER
gunzip RealSync/bin/$OS/$O_VER/*.gz
tar xvfC RealSync/bin/$OS/$O_VER/*.tar RealSync/bin/$OS/$O_VER/
rm -rf RealSync/bin/$OS/$O_VER/*.tar
ls -al RealSync/bin/$OS/$O_VER
echo ""
echo "The $R_VER RealSync SoftWare for $OS and $ORACLE_VER was get finished!"
}

get_6214_debug()
{
ftp -i -n 192.168.1.174  <<EOF
user release dsg@release
prompt off
bin
cd RealSync.debug/$SYSTEM/$ORA_VER
ls -ltr
lcd RealSync/bin/$OS
prompt off
bin
mls -ltr 
release.txt

exit
EOF

#R_VER=`sort RealSync/bin/$OS/release.txt |tail -1`
R_VER=`cat RealSync/bin/$OS/release.txt |grep oracle |awk '{print $9}' |tail -1`
echo $R_VER

ftp -i -n 192.168.1.174  <<EOF
user release dsg@release
prompt off
bin
cd RealSync.debug/$SYSTEM/$ORA_VER
lcd RealSync/bin/$OS
prompt off
bin
mget $R_VER
EOF

mkdir -p RealSync/bin/$OS/$O_VER
mv RealSync/bin/$OS/$R_VER RealSync/bin/$OS/$O_VER
gunzip RealSync/bin/$OS/$O_VER/*.gz
tar xvfC RealSync/bin/$OS/$O_VER/*.tar RealSync/bin/$OS/$O_VER/
rm -rf RealSync/bin/$OS/$O_VER/*.tar
ls -al RealSync/bin/$OS/$O_VER
echo ""
echo "The $R_VER RealSync SoftWare for $OS and $ORACLE_VER was get finished!"
}

echo "  "
echo "********************You will get RealSync SoftWare.********************"
read CLEAR_QUE?"Do you want clear all old RealSync version?(Y/N):"
while [ "$CLEAR_QUE" != "Y" -a "$CLEAR_QUE" != "y" -a "$CLEAR_QUE" != "N" -a "$CLEAR_QUE" != "n" ]
do
	CLEAR_QUE?"Do you want clear all old RealSync version?(Y/N):"
done
if [ "$CLEAR_QUE" = "Y" -o "$CLEAR_QUE" = "y" ]
then
    rm -rf RealSync/bin/*/*
    echo "Old RealSync version clear finished!"
else
    echo "No Clear old RealSync version"
fi

while true
do
  echo    "     "
  echo    "     Please choice your Operation System:"
  echo    "     1 AIX4.3"
  echo    "     2 AIX5L"
  echo    "     3 HP11.11"
  echo    "     4 HP11.23"
  echo    "     5 Linux"
  echo    "     6 SunOS5.8"
  echo    "     7 SunOS5.10"
  read CHOOSE_SYSTEM?"     please input your choice (1/2/3/4/5/6/7):"
  
  while [ "$CHOOSE_SYSTEM" != "1" -a "$CHOOSE_SYSTEM" != "2" -a "$CHOOSE_SYSTEM" != "3" -a \
          "$CHOOSE_SYSTEM" != "4" -a "$CHOOSE_SYSTEM" != "5" -a "$CHOOSE_SYSTEM" != "6" -a "$CHOOSE_SYSTEM" != "7" ]
  do
    read CHOOSE_SYSTEM?"     please input your choice (1/2/3/4/5/6/7):"
  done
  
  echo    "                                        "
  echo    "     Please choice your Oracle Version :"
  echo    "     1 ORACLE_8i"
  echo    "     2 ORACLE_9i"
  echo    "     3 ORACLE_10g"
  echo    "     4 ORACLE_11g"
  echo    "     5 ALL"
  read ORACLE_VERSION?"     please input your choice (1/2/3/4/5):"
  while [ "$ORACLE_VERSION" != "1" -a "$ORACLE_VERSION" != "2" -a "$ORACLE_VERSION" != "3" -a \
          "$ORACLE_VERSION" != "4" -a "$ORACLE_VERSION" != "5" ]
  do
    read ORACLE_VERSION?"     please input your choice (1/2/3/4/5):"
  done
  
  echo    "                                        "
  echo    "     Please choice RealSync Version :"
  echo    "     1 6.2.0.9.qa"
  echo    "     2 6.2.1.3.qa"
  echo    "     3 6.2.1.4.qa"
  echo    "     4 6.2.1.4.debug"
 
  read REAL_VERSION?"     please input your choice (1/2/3/4):"
  while [ "$REAL_VERSION" != "1" -a "$REAL_VERSION" != "2" -a "$REAL_VERSION" != "3" -a "$REAL_VERSION" != "4" ]
  do
    read REAL_VERSION?"     please input your choice (1/2/3/4):"
  done
  
  case "$CHOOSE_SYSTEM" in
  1)OS="AIX4.3"
    SYSTEM="AIX4.3";;
  2)OS="AIX5L"
    SYSTEM="AIX5.2";;
  3)OS="HP11.11"
    SYSTEM="HP-UX11.11";;
  4)OS="HP11.23"
    SYSTEM="HP-UX11.23";;
  5)OS="Linux"
    SYSTEM="Linux2.4";;
  6)OS="SunOS5.8"
    SYSTEM="SunOS5.8";;
  7)OS="SunOS5.10"
    SYSTEM="SunOS5.10_64bit";;
  esac
  
  case "$ORACLE_VERSION" in
  1)ORACLE_VER="ORACLE_8i"
    O_VER="8";;
  2)ORACLE_VER="ORACLE_9i"
    O_VER="9";;
  3)ORACLE_VER="ORACLE_10g"
    O_VER="10";;
  4)ORACLE_VER="ORACLE_11g"
    O_VER="11";;
  5)ORACLE_VER="ORACLE_ALL"
    O_VER="*";;
  esac
  
    case "$ORACLE_VERSION" in
  1)ORACLE_VER="ORACLE_8i"
    ORA_VER="8";;
  2)ORACLE_VER="ORACLE_9i"
    ORA_VER="oracle.9.2.0.4.0";;
  3)ORACLE_VER="ORACLE_10g"
    ORA_VER="oracle.10.2.0.1.0";;
  4)ORACLE_VER="ORACLE_11g"
    ORA_VER="oracle.11.2.0.1.0";;
  5)ORACLE_VER="ORACLE_ALL"
    ORA_VER="*";;
  esac
  
  case "$REAL_VERSION" in
  1)R_VER="6.2.0.9.qa";;
  2)R_VER="6.2.1.3.qa";;
  3)R_VER="6.2.1.4.qa";;
  4)R_VER="6.2.1.4.debug";;
  esac
  
  echo " "
  
  read ORACLE_QUE?"The version you want get RealSync SoftWare is $R_VER for $OS and $ORACLE_VER ?(Y/N):"
  while [ "$ORACLE_QUE" != "Y" -a "$ORACLE_QUE" != "y" -a "$ORACLE_QUE" != "N" -a "$ORACLE_QUE" != "n" ]
  do
  	read ORACLE_QUE?"The version you want get RealSync SoftWare is $R_VER for $OS and $ORACLE_VER ?(Y/N):"
  done
  
  if [ "$ORACLE_QUE" = "Y" -o "$ORACLE_QUE" = "y" ]
  then
      if [ "$R_VER" != "6.2.1.4.qa" ]
      then
          get_single
      fi
      if [ "$R_VER" = "6.2.1.4.qa" ]
      then
          get_6214_qa
      fi
      if [ "$R_VER" = "6.2.1.4.debug" ]
      then
          get_6214_debug
      fi

      read AGAIN_GET?"Do you want get other version?(Y/N):"
      while [ "$AGAIN_GET" != "Y" -a "$AGAIN_GET" != "y" -a "$AGAIN_GET" != "N" -a "$AGAIN_GET" != "n" ]
      do
      	read AGAIN_GET?"Do you want get other version?(Y/N):"
      done 
      if [ "$AGAIN_GET" = "Y" -o "$AGAIN_GET" = "y" ]
      then
          continue
      else
          echo "ByeBye...Welcome to come back next time! "
          break
      fi
  else
      echo ""
      echo " Choose Again......"
      continue
  fi

done

DATE=`date +%Y%m%d`
tar cvf RealSync_Install_$DATE.tar install RealSync
gzip RealSync_Install_$DATE.tar

exit
