--1
select sql_text from v$sqlarea where address = 
(select sql_address from v$session where paddr = 
 (select addr from v$process where spid='&PID')); 

--2
select thread#,sequence#,to_char(first_time,'YYYY-MM-DD HH24:MI:SS') time
from v$log_history
where to_char(first_time,'YYYY-MM-DD')='&time';

select count(*)
from v$log_history
where to_char(first_time,'YYYY-MM-DD')='&time';

select count(*)
from v$archived_log
where to_char(first_time,'YYYY-MM-DD')='&time';

select thread#,count(*)
from v$log_history
where to_char(first_time,'YYYY-MM-DD')='&time'
group by thread#;


select thread#,to_char(first_time,'YYYY-MM-DD') time,count(*)
from v$log_history
group by thread#,to_char(first_time,'YYYY-MM-DD')
order by thread#,count(*) asc;

select thread#,sequence#,to_char(first_time,'YYYY-MM-DD HH24:MI:SS') time
from v$log_history
where to_char(first_time,'YYYY-MM-DD')='&time'
order by thread#,sequence#;

select thread#,to_char(first_time,'YYYY-MM-DD HH24:MI:SS') time,count(*)
from v$log_history
where to_char(first_time,'YYYY-MM-DD')='&time'
group by thread#,to_char(first_time,'YYYY-MM-DD HH24:MI:SS')
order by thread#

select thread#,sequence#,to_char(first_time,'YYYY-MM-DD HH24:MI:SS') time,
       blocks*block_size/1024/1024 
from v$archived_log
where to_char(first_time,'YYYY-MM-DD')='&time'
order by thread#,sequence#

--3
SELECT
SUPPLEMENTAL_LOG_DATA_MIN LOG_MIN,
SUPPLEMENTAL_LOG_DATA_PK  LOG_PK,
SUPPLEMENTAL_LOG_DATA_UI  LOG_UK,
SUPPLEMENTAL_LOG_DATA_FK  LOG_FK,
SUPPLEMENTAL_LOG_DATA_ALL LOG_ALL
FROM V$DATABASE ;

--4
select * from (
select a.owner,b.table_name,sum(a.bytes/1024/1024/1024) 
from dba_segments a,dba_lobs b 
where a.segment_name=b.segment_name 
group by a.owner,b.table_name order by 3 desc )
where rownum<=50 order by 3;

--5
Select sum(bytes)/1024/1024/1024 
from dba_segments
where segment_type in ('TABLE', 'TABLE PARTITION');

select owner.segment_name, bytes/1024/1024/1024
from dba_Segments
where segment_type in ('TABLE', 'TABLE PARTITION') and bytes/1024/1024/1024>1;

Select owner, sum(bytes)/1024/1024/1024 
from dba_segments 
where segment_type in ('TABLE', 'TABLE PARTITION') 
group by owner 
order by 2;

Select owner, sum(bytes)/1024/1024/1024 
from dba_segments 
group by owner 
order by 2;

--6
select d.tablespace_name,
         space "SUM_SPACE(M)",
         blocks SUM_BLOCKS,
         SPACE-NVL(FREE_SPACE,0) "USED_SPACE(M)",
         round((1-NVL(FREE_SPACE,0)/SPACE)*100,2) "USED_RATE(%)",
         free_space "FREE_SPACE(M)"
  from (select tablespace_name,
         round(sum(bytes)/(1024*1024),2) space,
         sum(blocks) blocks
         from dba_data_files group by tablespace_name) d,
       (select tablespace_name,
         round(sum(bytes)/(1024*1024),2) free_space
         from dba_free_space group by tablespace_name) f
       where d.tablespace_name=f.tablespace_name(+)
union all
select d.tablespace_name,
         space "SUM_SPACE(M)",
         blocks SUM_BLOCKS,
         used_space "USED_SPACE(M)",
         round((1-NVL(used_SPACE,0)/SPACE)*100,2) "USED_RATE(%)",
         nvl(free_space,0) "FREE_SPACE(M)"
  from (select tablespace_name,round(sum(bytes)/(1024*1024),2) space,
         sum(blocks) blocks
         from dba_temp_files group by tablespace_name) d,
       (select tablespace_name,
         round(sum(bytes_used)/(1024*1024),2) USED_space,
         round(sum(bytes_FREE)/(1024*1024),2) FREE_space
         from v$temp_space_header group by tablespace_name) f
       where d.tablespace_name=f.tablespace_name(+);


