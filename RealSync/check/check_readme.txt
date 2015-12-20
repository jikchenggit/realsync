1������db link��Ŀ��˴�����
create database link dbverify
connect to dsg identified by dsg
using '(DESCRIPTION = (ADDRESS_LIST =(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.1.154)(PORT = 1521)))
                      (CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = db10)))'; 

2������������Ŀ��˴�����
--�ȶԵĵ�ǰ��������һ�εıȶ���Ϣ��

create table dsg.check_tab
(src_owner varchar2(30),    --Դ���û���
 src_table_name varchar2(30), --Դ�˱���
 tgt_owner varchar2(30),    --Ŀ����û���
 tgt_table_name varchar2(30), --Ŀ��˱���
 check_time date ,              --���ʱ��
 times   number,                 --������
 check_status char(1),        --�������ǣ�F��ʾ����д���T��ʾ�����ȷ
 flag number,                     --�����̱�ǣ�0��ʾδ��飬1��ʾ����꣬2��ʾ���ڼ�飬3��ʾ������
 src_count number,            --Դ�˼�¼��
 tgt_count number,            --Ŀ��˼�¼��
 diff_count number,            --���ļ�¼��
 minus_count number,         --���ݲ�һ�µļ�¼��
 minus_status char(1),         --minus����ǣ�Y��ʾ��ִ��minus��N��ʾ��ִ��minus
 m_times number,               --minus�ļ�����
 check_sql varchar2(1000),  --���ִ�е�sql���
 check_hxzb varchar2(200), --������ָ�꣬��Ҫִ��sum��������������ָ���������������֮���ö��Ÿ���
 hxzb_result  varchar2(200), --������ָ������ִ��sum�Ľ��
 err_msg varchar2(1000)      --������Ϣ
 );


--�ȶԵ���ʷ�������ʷ�ıȶ���Ϣ��

create table dsg.check_tab_his
(src_owner varchar2(30),    --Դ���û���
 src_table_name varchar2(30), --Դ�˱���
 tgt_owner varchar2(30),    --Ŀ����û���
 tgt_table_name varchar2(30), --Ŀ��˱���
 check_time date ,              --���ʱ��
 times   number,                 --������
 check_status char(1),        --�������ǣ�F��ʾ����д���T��ʾ�����ȷ
 flag number,                     --�����̱�ǣ�0��ʾδ��飬1��ʾ����꣬2��ʾ���ڼ�飬3��ʾ������
 src_count number,            --Դ�˼�¼��
 tgt_count number,            --Ŀ��˼�¼��
 diff_count number,            --���ļ�¼��
 minus_count number,         --���ݲ�һ�µļ�¼��
 minus_status char(1),         --minus����ǣ�Y��ʾ��ִ��minus��N��ʾ��ִ��minus
 m_times number,               --minus�ļ�����
 check_sql varchar2(1000),  --���ִ�е�sql���
 check_hxzb varchar2(200), --������ָ�꣬��Ҫִ��sum��������������ָ���������������֮���ö��Ÿ���
 hxzb_result  varchar2(200), --������ָ������ִ��sum�Ľ��
 err_msg varchar2(1000)      --������Ϣ
 );


׷����Ȩ��Ŀ�����Ȩ��
grant select any table to dsg;
grant select any dictionary to dsg;

3������Ҫ�ȶԵı�
--����Ҫ�ȶԵı������뵽dsg.check_tab���У����Դ����Ŀ��˵��û�����һ��������Ҫ����Ŀ��˵��û���
--����������ķ�ʽ��ͨ��dblink�ķ�ʽȥԴ�˲����Ҫ�ȶԵı���
����ǰ��û��ȶԵģ���Ҫ�޸�dsg.check_pkg.init_check��������ݣ��ĳ���Ҫ�ȶԵ��û�����

insert into dsg.check_tab (src_owner,src_table_name,tgt_owner,tgt_table_name)
select owner,table_name,owner,table_name from dba_tables@dbverify where owner='DSGTEST';


4������check_pkg��
--ͨ��check_pkg.sql�ű�����check_pkg��

--check_pkg���а����ļ����洢���̺������£�
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

check_pkg.init_check     :��ʼ�����̣�ÿ������checkǰ�������֮ǰ�ıȶ���Ϣд��his������յ�ǰ��ıȶ���Ϣ
check_pkg.re_check       :�ظ��ȶԹ��̣�����һ�αȶԵĽ������£������ȶԽ����һ�µı�������check��һ����
check_pkg.re_minus       :�ظ�minus�ȶԹ��̣�����һ�αȶԵĽ������£������ȶԽ����һ�µı�������minus��һ����
check_pkg.start_check    :��ʼ�ȶ�--�ȶԼ�¼��
check_pkg.stop_check     :ֹͣ�ȶ�
procedure start_minus    :��ʼminus�ȶԣ�minus�ȶ�ʱ���Զ����˵���LONG��LONG RAW��LOB���͵ı�
procedure stop_minus     :ֹͣminus�ȶ�
check_pkg.check_proc     :�ȶԵ����ű�����start_check���̵��ã������޸ĸù����еĲ�����ѯ������Ĭ��Ϊ8����select /*+parallel(dc,8)+*/ �����޸�parallel�����ֵ������
procedure minus_proc     :minus�ȶԵ����ű�����start_minus���̵��ã������޸ĸù����еĲ�����ѯ������Ĭ��Ϊ8����select /*+parallel(dc,8)+*/ �����޸�parallel�����ֵ������


5����ִ̨�нű����ű��е����롢�������Ϳ��Ըģ�
start_check.sh        --��ʼ�ȶԽű���Ĭ�ϲ�������1��Ĭ�ϵļ��������count��minus,���Ը�����Ҫ�����޸�
stop_check.sh         --ֹͣ�ȶԽű�
re_check.sh            --���±ȶ��ϴαȶԲ�һ�µı�Ĭ�ϲ�������1��Ĭ�ϵļ��������count��minus,���Ը�����Ҫ�����޸�

start_check.sh 10  --��ʾָ��������10
re_check.sh 10  --��ʾָ��������10


6���鿴�ȶԽ��
select * from dsg.check_tab where check_status='F';

check_status='T' ��ʾ�ȶԽ����ȷ��'F'��ʾ�ȶԽ����һ��

select * from dsg.check_tab where check_status='F' order by diff_count,minus_count desc;

7���鿴��ʷ�ȶ���Ϣ
select * from dsg.check_tab_his


