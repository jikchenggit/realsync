create table dsg.monitor_tabs
(id number primary key,
 service_name varchar2(30),
 log_path varchar2(200),
 err_type varchar2(30),
 err_time date,
 err_msg varchar2(4000)
);

create table dsg.delay_time_tabs
(service_name varchar2(30),
 queue_name varchar2(30),
 check_time date,
 xf1_cache_count number,
 delay_time number,
 src_scn_time date
);

create table dsg.delay_time_his_tabs
(service_name varchar2(30),
 queue_name varchar2(30),
 check_time date,
 xf1_cache_count number,
 delay_time number,
 src_scn_time date
);
