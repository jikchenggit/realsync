select 'exec sys.dbms_ijob.broken('||job||',true);'||chr(10)||'commit;' from dba_jobs where broken='N';
select 'exec dbms_scheduler.disable('''||owner||'.'||job_name||''');' from dba_scheduler_jobs where enabled='TRUE';


set serveroutput on
declare
    v_job_id number;
    v_user varchar2(50);
    v_nlsenv VARCHAR2(4000);
    cursor c_tab is select job,schema_user,nls_env from dba_jobs where log_user='DSG';
begin
    open c_tab;
    loop
         fetch c_tab into v_job_id,v_user,v_nlsenv;
         exit when c_tab%NOTFOUND;
         sys.dbms_ijob.CHANGE_ENV(v_job_id,v_user,v_user,v_user,v_nlsenv);   
         commit;
    end loop;
    close c_tab;
end;
/
