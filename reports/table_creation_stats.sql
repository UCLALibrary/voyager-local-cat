set linesize 80;
column object_name format a50;
column created format a20;
select object_name, to_char(created, 'YYYY-MM-DD HH24:MI:SS') as created 
from user_objects where object_type = 'TABLE' and created >= trunc(sysdate) order by created;

