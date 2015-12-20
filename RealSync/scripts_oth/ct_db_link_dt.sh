sqlplus -s dsg/dsg <<EOF
set timing on
drop database link dbverify;
create database link dbverify
connect to dsg identified by dsg
using '(DESCRIPTION = (ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.156)(PORT = 1521)))
                      (CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = db10)))'; 
select host_name from v\$instance@dbverify;
exit;
EOF
