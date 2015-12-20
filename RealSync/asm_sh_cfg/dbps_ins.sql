-- Please make sure the max_open_cursors in init.ora file > 1000
-- connect internal;

create or replace view DBPS_XKCCLE as select * from sys.x$kccle;
create or replace view DBPS_XKCCLH as select * from sys.x$kcclh;
create or replace view DBPS_XKCCCF as select * from sys.x$kcccf;
create or replace view DBPS_XKCCCP as select * from sys.x$kcccp;
create or replace view DBPS_XKCCDI as select * from sys.x$kccdi;
create or replace view DBPS_XKCRMF as select * from sys.x$kcrmf;
create or replace view DBPS_XKTUXE as select * from sys.x$ktuxe;
create or replace view DBPS_XLE    as select * from sys.x$le;
create or replace view DBPS_XBH    as select * from sys.x$bh;

create or replace view DBPS_XKTFBFE as
select fi.file#, f.block#, f.length
from sys.fet$ f, sys.file$ fi
where f.ts# = fi.ts# and f.file# = fi.relfile#
union all
select fi.file#, f.ktfbfebno, f.ktfbfeblks
from sys.x$ktfbfe f, sys.file$ fi
where f.ktfbfetsn = fi.ts# and f.ktfbfefno = fi.relfile#
;
