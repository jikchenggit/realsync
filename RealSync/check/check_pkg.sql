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
/

create or replace package body dsg.check_pkg as
  procedure init_check as
    v_ddl_sql varchar2(1000);
  begin
    insert into dsg.check_tab_his
      select * from dsg.check_tab;
    commit;
    v_ddl_sql := 'truncate table dsg.check_tab';
    execute immediate v_ddl_sql;
    insert into dsg.check_tab
      (src_owner, src_table_name, tgt_owner, tgt_table_name)
      select owner, table_name, owner, table_name
        from dba_tables@dbverify
       where owner = 'DSGTEST';
    commit;
    update dsg.check_tab
       set check_time   = null,
           times        = 0,
           m_times      = 0,
           check_status = 'F',
           flag         = 0,
           src_count    = 0,
           tgt_count    = 0,
           diff_count   = null,
           minus_count  = null,
           minus_status = 'N',
           check_sql    = null,
           hxzb_result  = null,
           err_msg      = null;
    commit;
    update dsg.check_tab
       set minus_status = 'Y'
     where (tgt_owner, tgt_table_name) not in
           (select distinct owner, table_name
              from dba_tab_columns
             where data_type in ('LONG', 'LONG RAW', 'BLOB', 'CLOB'));
    commit;
  end init_check;
  procedure re_check as
  begin
    update dsg.check_tab
       set flag = 0
     where (diff_count != 0 or diff_count is null);
    commit;
  end re_check;
  procedure re_minus as
  begin
    update dsg.check_tab
       set flag = 0
     where (diff_count = 0 or diff_count is null)
       and (minus_count != 0 or minus_count is null)
       and minus_status = 'Y';
    commit;
  end re_minus;
  procedure start_check as
  begin
    update dsg.check_tab set flag = 0 where diff_count != 0 or diff_count is null;
    commit;
    check_proc;
  end start_check;
  procedure stop_check as
  begin
    update dsg.check_tab set flag = 1 where flag = 0;
    commit;
  end stop_check;
  procedure start_minus as
  begin
    update dsg.check_tab
       set flag = 0
     where (diff_count = 0 or diff_count is null)
       and (minus_count != 0 or minus_count is null)
       and minus_status = 'Y';
    commit;
    minus_proc;
  end start_minus;
  procedure stop_minus as
  begin
    update dsg.check_tab
       set flag = 4
     where (diff_count = 0 or diff_count is null)
       and (minus_count != 0 or minus_count is null)
       and minus_status = 'Y';
    commit;
  end stop_minus;
  procedure check_proc as
    v_src_owner    varchar2(30);
    v_src_tab_name varchar2(30);
    v_tgt_owner    varchar2(30);
    v_tgt_tab_name varchar2(30);
    v_src_ck_count number;
    v_tgt_ck_count number;
    v_ck_tab       number;
    v_src_sql      varchar2(1000);
    v_tgt_sql      varchar2(1000);
    v_chk_sql      varchar2(1000);
    v_hxzb         varchar2(100);
    v_hxzb_ck      number;
    v_in           number;
    v_err_msg      varchar2(1000);
    v_src_ck_sum   number;
    v_tgt_ck_sum   number;
    v_minus_sum    number;
  begin
    while true loop
      select count(1)
        into v_ck_tab
        from dsg.check_tab
       where flag = 0
         and (diff_count != 0 or diff_count is null);
      if v_ck_tab > 0 then
        begin
          select count(1)
            into v_ck_tab
            from dsg.check_tab
           where flag = 0
             and (diff_count != 0 or diff_count is null);
          select src_owner, src_table_name, tgt_owner, tgt_table_name
            into v_src_owner, v_src_tab_name, v_tgt_owner, v_tgt_tab_name
            from dsg.check_tab
           where flag = 0
             and (diff_count != 0 or diff_count is null)
             and rownum <= 1
             for update;
          update dsg.check_tab
             set check_time = sysdate, times = times + 1, flag = 2
           where src_owner = v_src_owner
             and src_table_name = v_src_tab_name;
          commit;
          v_src_sql := 'select /*+parallel(dc,8)+*/ count(1) from "' ||
                       v_src_owner || '"."' || v_src_tab_name ||
                       '"@dbverify dc';
          v_tgt_sql := 'select /*+parallel(dc,8)+*/ count(1) from "' ||
                       v_tgt_owner || '"."' || v_tgt_tab_name || '" dc';
          v_chk_sql := v_src_sql || chr(10) || v_tgt_sql;
          execute immediate v_src_sql
            into v_src_ck_count;
          execute immediate v_tgt_sql
            into v_tgt_ck_count;
          if v_src_ck_count != v_tgt_ck_count then
            update dsg.check_tab
               set src_count    = v_src_ck_count,
                   tgt_count    = v_tgt_ck_count,
                   diff_count   = v_src_ck_count - v_tgt_ck_count,
                   flag         = 1,
                   check_status = 'F',
                   check_sql    = v_chk_sql
             where src_owner = v_src_owner
               and src_table_name = v_src_tab_name;
            commit;
          else
            update dsg.check_tab
               set src_count    = v_src_ck_count,
                   tgt_count    = v_tgt_ck_count,
                   diff_count   = 0,
                   flag         = 1,
                   check_status = 'T',
                   check_sql    = v_chk_sql
             where src_owner = v_src_owner
               and src_table_name = v_src_tab_name;
            commit;
          end if;
          select count(1)
            into v_hxzb_ck
            from dsg.check_tab
           where src_owner = v_src_owner
             and src_table_name = v_src_tab_name
             and check_hxzb is not null;
          if v_hxzb_ck > 0 then
            select check_hxzb
              into v_hxzb
              from dsg.check_tab
             where src_owner = v_src_owner
               and src_table_name = v_src_tab_name;
            while true loop
              select instr(v_hxzb, ',') into v_in from dual;
              if v_in = 0 then
                v_src_sql := 'select /*+parallel(dc,8)+*/ sum(' || v_hxzb ||
                             ') from "' || v_src_owner || '"."' ||
                             v_src_tab_name || '"@dbverify dc';
                v_tgt_sql := 'select /*+parallel(dc,8)+*/  sum(' || v_hxzb ||
                             ') from "' || v_tgt_owner || '"."' ||
                             v_tgt_tab_name || '" dc';
                v_chk_sql := v_src_sql || chr(10) || v_tgt_sql;
                execute immediate v_src_sql
                  into v_src_ck_sum;
                execute immediate v_tgt_sql
                  into v_tgt_ck_sum;
                if v_src_ck_sum != v_tgt_ck_sum then
                  v_minus_sum := v_src_ck_sum - v_tgt_ck_sum;
                  update dsg.check_tab
                     set check_status = 'F',
                         check_sql    = check_sql || chr(10) || v_chk_sql,
                         hxzb_result  = decode(hxzb_result,
                                               null,
                                               v_hxzb || '=' || v_src_ck_sum ||
                                               '(S)-' || v_tgt_ck_sum ||
                                               '(T)=' || v_minus_sum,
                                               hxzb_result || chr(10) ||
                                               v_hxzb || '=' || v_src_ck_sum ||
                                               '(S)-' || v_tgt_ck_sum ||
                                               '(T)=' || v_minus_sum)
                   where src_owner = v_src_owner
                     and src_table_name = v_src_tab_name;
                  commit;
                else
                  v_minus_sum := v_src_ck_sum - v_tgt_ck_sum;
                  update dsg.check_tab
                     set check_status = 'T',
                         check_sql    = check_sql || chr(10) || v_chk_sql,
                         hxzb_result  = decode(hxzb_result,
                                               null,
                                               v_hxzb || '=' || v_src_ck_sum ||
                                               '(S)-' || v_tgt_ck_sum ||
                                               '(T)=' || v_minus_sum,
                                               hxzb_result || chr(10) ||
                                               v_hxzb || '=' || v_src_ck_sum ||
                                               '(S)-' || v_tgt_ck_sum ||
                                               '(T)=' || v_minus_sum)
                   where src_owner = v_src_owner
                     and src_table_name = v_src_tab_name;
                  commit;
                end if;
                exit;
              else
                v_src_sql := 'select /*+parallel(dc,8)+*/ sum(' ||
                             substr(v_hxzb, 1, v_in - 1) || ') from "' ||
                             v_src_owner || '"."' || v_src_tab_name ||
                             '"@dbverify dc';
                v_tgt_sql := 'select /*+parallel(dc,8)+*/  sum(' ||
                             substr(v_hxzb, 1, v_in - 1) || ') from "' ||
                             v_tgt_owner || '"."' || v_tgt_tab_name ||
                             '" dc';
                v_chk_sql := v_src_sql || chr(10) || v_tgt_sql;
                execute immediate v_src_sql
                  into v_src_ck_sum;
                execute immediate v_tgt_sql
                  into v_tgt_ck_sum;
                if v_src_ck_sum != v_tgt_ck_sum then
                  v_minus_sum := v_src_ck_sum - v_tgt_ck_sum;
                  update dsg.check_tab
                     set check_status = 'F',
                         check_sql    = check_sql || chr(10) || v_chk_sql,
                         hxzb_result  = decode(hxzb_result,
                                               null,
                                               substr(v_hxzb, 1, v_in - 1) || '=' ||
                                               v_src_ck_sum || '(S)-' ||
                                               v_tgt_ck_sum || '(T)=' ||
                                               v_minus_sum,
                                               hxzb_result || chr(10) ||
                                               v_hxzb || '=' || v_src_ck_sum ||
                                               '(S)-' || v_tgt_ck_sum ||
                                               '(T)=' || v_minus_sum)
                   where src_owner = v_src_owner
                     and src_table_name = v_src_tab_name;
                  commit;
                else
                  v_minus_sum := v_src_ck_sum - v_tgt_ck_sum;
                  update dsg.check_tab
                     set check_status = 'T',
                         check_sql    = check_sql || chr(10) || v_chk_sql,
                         hxzb_result  = decode(hxzb_result,
                                               null,
                                               substr(v_hxzb, 1, v_in - 1) || '=' ||
                                               v_src_ck_sum || '(S)-' ||
                                               v_tgt_ck_sum || '(T)=' ||
                                               v_minus_sum,
                                               hxzb_result || chr(10) ||
                                               v_hxzb || '=' || v_src_ck_sum ||
                                               '(S)-' || v_tgt_ck_sum ||
                                               '(T)=' || v_minus_sum)
                   where src_owner = v_src_owner
                     and src_table_name = v_src_tab_name;
                  commit;
                end if;
                v_hxzb := substr(v_hxzb, v_in + 1);
              end if;
            end loop;
          end if;
        exception
          when others then
            v_err_msg := sqlerrm;
            update dsg.check_tab
               set flag = 3, err_msg = v_err_msg
             where src_owner = v_src_owner
               and src_table_name = v_src_tab_name;
            commit;
        end;
      else
        exit;
      end if;
    end loop;
  end check_proc;
  procedure minus_proc as
    v_src_owner    varchar2(30);
    v_src_tab_name varchar2(30);
    v_tgt_owner    varchar2(30);
    v_tgt_tab_name varchar2(30);
    v_minus_count  number;
    v_ck_tab       number;
    v_src_sql      varchar2(1000);
    v_tgt_sql      varchar2(1000);
    v_minus_sql    varchar2(1000);
    v_err_msg      varchar2(1000);
  begin
    while true loop
      select count(1)
        into v_ck_tab
        from dsg.check_tab
       where minus_status = 'Y'
         and (diff_count = 0 or diff_count is null)
         and flag in (0, 1);
      if v_ck_tab > 0 then
        begin
          select count(1)
            into v_ck_tab
            from dsg.check_tab
           where minus_status = 'Y'
             and (diff_count = 0 or diff_count is null)
             and flag in (0, 1);
          select src_owner, src_table_name, tgt_owner, tgt_table_name
            into v_src_owner, v_src_tab_name, v_tgt_owner, v_tgt_tab_name
            from dsg.check_tab
           where minus_status = 'Y'
             and (diff_count = 0 or diff_count is null)
             and flag in (0, 1)
             and rownum <= 1
             for update;
          update dsg.check_tab
             set check_time = sysdate, m_times = m_times + 1, flag = 2
           where src_owner = v_src_owner
             and src_table_name = v_src_tab_name;
          commit;
          v_minus_count := 0;
          v_src_sql     := 'select /*+parallel(dc,8)+*/ * from "' ||
                           v_src_owner || '"."' || v_src_tab_name ||
                           '"@dbverify dc';
          v_tgt_sql     := 'select /*+parallel(dc,8)+*/ * from "' ||
                           v_tgt_owner || '"."' || v_tgt_tab_name || '" dc';
          v_minus_sql   := 'select count(*) from (';
          v_minus_sql   := v_minus_sql || chr(10) || v_src_sql;
          v_minus_sql   := v_minus_sql || chr(10) || 'minus';
          v_minus_sql   := v_minus_sql || chr(10) || v_tgt_sql || ')';
          execute immediate v_minus_sql
            into v_minus_count;
          if v_minus_count != 0 then
            update dsg.check_tab
               set minus_count  = v_minus_count,
                   flag         = 4,
                   check_status = 'F',
                   check_sql    = decode(m_times,
                                         1,
                                         check_sql || chr(10) || v_minus_sql,
                                         check_sql)
             where src_owner = v_src_owner
               and src_table_name = v_src_tab_name;
            commit;
          else
            update dsg.check_tab
               set minus_count  = v_minus_count,
                   flag         = 4,
                   check_status = 'T',
                   check_sql    = decode(m_times,
                                         1,
                                         check_sql || chr(10) || v_minus_sql,
                                         check_sql)
             where src_owner = v_src_owner
               and src_table_name = v_src_tab_name;
            commit;
          end if;
        exception
          when others then
            v_err_msg := sqlerrm;
            update dsg.check_tab
               set flag = 3, err_msg = v_err_msg
             where src_owner = v_src_owner
               and src_table_name = v_src_tab_name;
            commit;
        end;
      else
        exit;
      end if;
    end loop;
  end minus_proc;
end check_pkg;
/