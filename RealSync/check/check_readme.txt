1、创建db link（目标端创建）
create database link dbverify
connect to dsg identified by dsg
using '(DESCRIPTION = (ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.154)(PORT = 1521)))
                      (CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = db10)))'; 

2、创建两个表（目标端创建）
--比对的当前表（存放最近一次的比对信息）

create table dsg.check_tab
(src_owner varchar2(30),    --源端用户名
 src_table_name varchar2(30), --源端表名
 tgt_owner varchar2(30),    --目标端用户名
 tgt_table_name varchar2(30), --目标端表名
 check_time date ,              --检查时间
 times   number,                 --检查次数
 check_status char(1),        --检查结果标记，F表示结果有错误，T表示结果正确
 flag number,                     --检查过程标记，0表示未检查，1表示检查完，2表示正在检查，3表示检查出错
 src_count number,            --源端记录数
 tgt_count number,            --目标端记录数
 diff_count number,            --相差的记录数
 minus_count number,         --内容不一致的记录数
 minus_status char(1),         --minus检查标记，Y表示有执行minus，N表示不执行minus
 m_times number,               --minus的检查次数
 check_sql varchar2(1000),  --检查执行的sql语句
 check_hxzb varchar2(200), --检查核心指标，需要执行sum检查的列名，可以指定多个列名，列名之间用逗号隔开
 hxzb_result  varchar2(200), --检查核心指标结果，执行sum的结果
 err_msg varchar2(1000)      --报错信息
 );


--比对的历史表（存放历史的比对信息）

create table dsg.check_tab_his
(src_owner varchar2(30),    --源端用户名
 src_table_name varchar2(30), --源端表名
 tgt_owner varchar2(30),    --目标端用户名
 tgt_table_name varchar2(30), --目标端表名
 check_time date ,              --检查时间
 times   number,                 --检查次数
 check_status char(1),        --检查结果标记，F表示结果有错误，T表示结果正确
 flag number,                     --检查过程标记，0表示未检查，1表示检查完，2表示正在检查，3表示检查出错
 src_count number,            --源端记录数
 tgt_count number,            --目标端记录数
 diff_count number,            --相差的记录数
 minus_count number,         --内容不一致的记录数
 minus_status char(1),         --minus检查标记，Y表示有执行minus，N表示不执行minus
 m_times number,               --minus的检查次数
 check_sql varchar2(1000),  --检查执行的sql语句
 check_hxzb varchar2(200), --检查核心指标，需要执行sum检查的列名，可以指定多个列名，列名之间用逗号隔开
 hxzb_result  varchar2(200), --检查核心指标结果，执行sum的结果
 err_msg varchar2(1000)      --报错信息
 );


追加授权（目标端授权）
grant select any table to dsg;
grant select any dictionary to dsg;

3、插入要比对的表
--把需要比对的表名插入到dsg.check_tab表中，如果源端与目标端的用户名不一样，还需要设置目标端的用户名
--可以用下面的方式，通过dblink的方式去源端查出需要比对的表名
如果是按用户比对的，需要修改dsg.check_pkg.init_check里面的内容，改成需要比对的用户即可

insert into dsg.check_tab (src_owner,src_table_name,tgt_owner,tgt_table_name)
select owner,table_name,owner,table_name from dba_tables@dbverify where owner='DSGTEST';


4、创建check_pkg包
--通过check_pkg.sql脚本创建check_pkg包

--check_pkg包中包含的几个存储过程含义如下：
create or replace package dsg.check_pkg
as
procedure init_check;
procedure re_check;
procedure re_minus;
procedure start_check;
procedure stop_check;
procedure start_minus;
procedure stop_minus;
procedure check_proc;
procedure minus_proc;
end check_pkg;

check_pkg.init_check     :初始化过程，每次重新check前，都会把之前的比对信息写入his表，并清空当前表的比对信息
check_pkg.re_check       :重复比对过程，在上一次比对的结果情况下，继续比对结果不一致的表（跟重新check不一样）
check_pkg.re_minus       :重复minus比对过程，在上一次比对的结果情况下，继续比对结果不一致的表（跟重新minus不一样）
check_pkg.start_check    :开始比对--比对记录数
check_pkg.stop_check     :停止比对
procedure start_minus    :开始minus比对，minus比对时，自动过滤掉含LONG、LONG RAW、LOB类型的表
procedure stop_minus     :停止minus比对
check_pkg.check_proc     :比对的主脚本，被start_check过程调用，可以修改该过程中的并发查询个数（默认为8）（select /*+parallel(dc,8)+*/ ），修改parallel后面的值，即可
procedure minus_proc     :minus比对的主脚本，被start_minus过程调用，可以修改该过程中的并发查询个数（默认为8）（select /*+parallel(dc,8)+*/ ），修改parallel后面的值，即可


5、后台执行脚本（脚本中的密码、检查的类型可以改）
start_check.sh        --开始比对脚本，默认并发数是1，默认的检查内容是count及minus,可以根据需要进行修改
stop_check.sh         --停止比对脚本
re_check.sh            --重新比对上次比对不一致的表，默认并发数是1，默认的检查内容是count及minus,可以根据需要进行修改

start_check.sh 10  --表示指定并发数10
re_check.sh 10  --表示指定并发数10


6、查看比对结果
select * from dsg.check_tab where check_status='F';

check_status='T' 表示比对结果正确，'F'表示比对结果不一致

select * from dsg.check_tab where check_status='F' order by diff_count,minus_count desc;

7、查看历史比对信息
select * from dsg.check_tab_his


