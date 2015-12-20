create database link dbverify
connect to dsg identified by dsg
using '(DESCRIPTION = (ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST = 130.75.3.6)(PORT = 2268)))
                      (CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = jxcrm)))'; 

create table dsg.rule_tables
(
 owner varchar2(30),
 table_name varchar2(30),
 rule varchar2(50),
 primary key (owner,table_name));

create table dsg.check_tab
(src_owner varchar2(30),
 src_table_name varchar2(30),
 tgt_owner varchar2(30),
 tgt_table_name varchar2(30),
 rule varchar2(50),
 check_time date ,
 times   number,
 check_status char(1),
 flag number,
 src_count number,
 tgt_count number,
 diff_count number,
 minus_count number,
 minus_status char(1),
 m_times number,
 check_sql varchar2(1000),
 check_hxzb varchar2(200),
 hxzb_result  varchar2(200),
 err_msg varchar2(1000)
 );

create table dsg.check_tab_his
(src_owner varchar2(30),
 src_table_name varchar2(30),
 tgt_owner varchar2(30),
 tgt_table_name varchar2(30),
 rule varchar2(50),
 check_time date ,
 times   number,
 check_status char(1),
 flag number,
 src_count number,
 tgt_count number,
 diff_count number,
 minus_count number,
 minus_status char(1),
 m_times number,
 check_sql varchar2(1000),
 check_hxzb varchar2(200),
 hxzb_result  varchar2(200),
 err_msg varchar2(1000)
 );

comment on column dsg.check_tab.src_owner      is '源端用户名';
comment on column dsg.check_tab.src_table_name is '源端表名';
comment on column dsg.check_tab.tgt_owner      is '目标端用户名';
comment on column dsg.check_tab.tgt_table_name is '目标端表名';
comment on column dsg.check_tab.rule           is '下发规则,需要设置的条件';
comment on column dsg.check_tab.check_time     is '检查时间';
comment on column dsg.check_tab.times          is '检查次数';
comment on column dsg.check_tab.check_status   is '检查结果标记，F表示结果有错误，T表示结果正确';
comment on column dsg.check_tab.flag           is '检查过程标记，0表示未检查，1表示检查完，2表示正在检查，3表示检查出错，4表示minus检查完成';
comment on column dsg.check_tab.src_count      is '源端记录数';
comment on column dsg.check_tab.tgt_count      is '目标端记录数';
comment on column dsg.check_tab.diff_count     is '相差的记录数';
comment on column dsg.check_tab.minus_count    is '内容不一致的记录数';
comment on column dsg.check_tab.minus_status   is 'minus检查标记，Y表示有执行minus，N表示不执行minus';
comment on column dsg.check_tab.m_times        is 'minus的检查次数';
comment on column dsg.check_tab.check_sql      is '检查执行的sql语句';
comment on column dsg.check_tab.check_hxzb     is '检查核心指标，需要执行sum检查的列名，可以指定多个列名，列名之间用逗号隔开';
comment on column dsg.check_tab.hxzb_result    is '检查核心指标结果，执行sum的结果';
comment on column dsg.check_tab.err_msg        is '报错信息';
