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

comment on column dsg.check_tab.src_owner      is 'Դ���û���';
comment on column dsg.check_tab.src_table_name is 'Դ�˱���';
comment on column dsg.check_tab.tgt_owner      is 'Ŀ����û���';
comment on column dsg.check_tab.tgt_table_name is 'Ŀ��˱���';
comment on column dsg.check_tab.rule           is '�·�����,��Ҫ���õ�����';
comment on column dsg.check_tab.check_time     is '���ʱ��';
comment on column dsg.check_tab.times          is '������';
comment on column dsg.check_tab.check_status   is '�������ǣ�F��ʾ����д���T��ʾ�����ȷ';
comment on column dsg.check_tab.flag           is '�����̱�ǣ�0��ʾδ��飬1��ʾ����꣬2��ʾ���ڼ�飬3��ʾ������4��ʾminus������';
comment on column dsg.check_tab.src_count      is 'Դ�˼�¼��';
comment on column dsg.check_tab.tgt_count      is 'Ŀ��˼�¼��';
comment on column dsg.check_tab.diff_count     is '���ļ�¼��';
comment on column dsg.check_tab.minus_count    is '���ݲ�һ�µļ�¼��';
comment on column dsg.check_tab.minus_status   is 'minus����ǣ�Y��ʾ��ִ��minus��N��ʾ��ִ��minus';
comment on column dsg.check_tab.m_times        is 'minus�ļ�����';
comment on column dsg.check_tab.check_sql      is '���ִ�е�sql���';
comment on column dsg.check_tab.check_hxzb     is '������ָ�꣬��Ҫִ��sum��������������ָ���������������֮���ö��Ÿ���';
comment on column dsg.check_tab.hxzb_result    is '������ָ������ִ��sum�Ľ��';
comment on column dsg.check_tab.err_msg        is '������Ϣ';
