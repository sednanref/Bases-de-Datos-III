define FILE=datafiles.sql
SET ECHO OFF;
SET PAGESIZE 50;
SET LINESIZE 150;
SET HEADING OFF;
spool &FILE
select 'ALTER TABLESPACE '|| RTRIM(tablespace_name) ||
      ' ADD DATAFILE ' || chr(39) ||
       SUBSTR(file_name,1,INSTR(file_name,'.',1,1)-1) ||
      'automatic.dbf'|| chr(39) || ' SIZE ' ||
       RTRIM(BYTES/1024) || 'K AUTOEXTEND '||
       RTRIM(DECODE(autoextensible, 'YES', 'ON NEXT '||
       RTRIM(INCREMENT_BY)||' MAXSIZE '||
       RTRIM(MAXBYTES/1024)||'K', 'OFF'))||' ;'
from  dba_temp_files t
where tablespace_name in (select tablespace_name
                         from dba_temp_files
                         group by tablespace_name
                         having (sum(maxbytes-bytes)/1024)/1024<2049)
     and  file_id=(select min(file_id)
                from dba_temp_files t1
                where t.tablespace_name=t1.tablespace_name);
spool off;
SET HEADING ON;