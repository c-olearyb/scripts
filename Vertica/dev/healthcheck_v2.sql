\timing
--Get Sysdate
\!echo "Select sysdate from dual;#####################################################################################################"
select sysdate from dual;




--Canary Query
\!echo "Canary Query;#####################################################################################################"
select * from databases;




--GET_AHM_TIME
\!echo "GET_AHM_TIME##########################################################################################################"
\!echo "If TIME_AGO is higher than 1 hour, consider run SELECT MAKE_AHM_NOW();"
select sysdate, min(epoch_close_time at time zone 'utc')min_epoch, to_char(sysdate-min(epoch_close_time at time zone 'utc'),'yyyy-mm-dd hh24:mi:ss')time_ago from epochs;





--Nodes status
\!echo "Nodes not in UP status############################################################################################################"
select node_name, node_state, node_address, export_address, catalog_path from nodes where node_state<>'UP';




--Delete Vectors
\!echo "Delete Vectors;#####################################################################################################"
select t1.schema_name, t2.anchor_table_name,  sum(deleted_row_count) sum_del_rows, sum(used_bytes) sum_del_bytes,
'select do_tm_task(' || CHR(39) || 'mergeout' ||CHR(39) ||', '||CHR(39) || t1.schema_name || '.' || anchor_table_name || chr(39) || ');' as tm_to_run
from delete_vectors t1, projections t2
where t1.schema_name = t2.projection_schema
and t1.projection_name = t2.projection_name
group by 1,2,5 order by 3 DESC;




--Query Memory in use by Query
\!echo "Query Memory in use;#####################################################################################################"
SELECT SUM(r.MEMORY_INUSE_KB), q.USER_NAME, q.SESSION_ID, q.REQUEST
FROM QUERY_REQUESTS q, RESOURCE_ACQUISITIONS r
WHERE r.TRANSACTION_ID = q.TRANSACTION_ID
AND r.STATEMENT_ID = q.STATEMENT_ID
AND q.IS_EXECUTING = 't' 
/*  AND q.REQUEST NOT ILIKE '%DIRECT%'  */
GROUP BY 2,3,4 ORDER BY 1 DESC;




--Check rejected queries
\!echo "Check Rejected queries#####################################################################################################"
select * from resource_rejections order by last_rejected_timestamp desc limit 10;




--Total & inactive sessions
\!echo "Total & inactive sessions###############################################################################################"
select 
(Select 'Total sessions: '||count(*) from sessions) Total, 
(Select 'Active sessions without transactions: '||count(*) from sessions where transaction_id <> -1) Inactive
from dual;




--Locks
\!echo "Locks###################################################################################################################"
select
--node_names,
object_name,
--object_id,
(select user_name from sessions where transaction_id = lks.transaction_id) transaction_user,
lock_mode,
decode (lock_mode,
'S','Shared',
'I','Insert',
'SI','SharedInsert',
'X','Exclusive',
'T','Tuple Mover',
'U','Usage',
'O','Owner',
'NONE')
lock_scope,
request_timestamp,
grant_timestamp,
left(REGEXP_REPLACE(transaction_description,'[\r\t\f\n]',' '),120)||'...' short_transaction_description,
qr.transaction_id,
user_name, session_id, success, is_executing
from locks lks, query_requests qr
where lks.transaction_id = qr.transaction_id
and is_executing = true;




--Lock count
\!echo "Lock count##############################################################################################################"
select
object_name,
decode (lock_mode,'S','Shared','I','Insert','SI','SharedInsert','X','Exclusive','T','Tuple Mover','U','Usage','O','Owner','NONE'),
lock_scope,
Count(*)
from locks
group by object_name,lock_mode,lock_scope
order by 1;




--Lock usage
\!echo "lock usage##############################################################################################################"
--Lock usage
Select
session_id, 
(select user_name from sessions where session_id = LUS.session_id)user_name,
object_name,
mode_scope,
avg_hold_time,
max_hold_time,
hold_count,
avg_wait_time,
max_wait_time,
wait_count
from (
select
--node_name,
session_id,
object_name,
--mode,
decode (mode,
'S','Shared',
'I','Insert',
'SI','SharedInsert',
'X','Exclusive',
'T','Tuple Mover',
'U','Usage',
'O','Owner',
'NONE') mode_scope,
to_char(avg(avg_hold_time))avg_hold_time,
to_char(avg(max_hold_time))max_hold_time,
sum(hold_count)hold_count,
to_char(avg(avg_wait_time))avg_wait_time,
to_char(avg(max_wait_time))max_wait_time,
sum(wait_count)wait_count
from lock_usage LU
where 
wait_count > 0
and Session_id in (select session_id from sessions)
group by 
session_id,
object_name,
mode_scope) LUS
order by LUS.session_id, LUS.max_wait_time desc;




--Percentage of sessions per node
\!echo "Percentage of sessions per node#########################################################################################"
select
	node_name,
	Sessions_per_node,
	to_char(round((Sessions_per_node/total_sessions)*100,2),'999,999,999,999,999.999') Percent_sessions
from
(
   select
      node_name, 
      count(*) Sessions_per_node, 
      sess.total_sessions
   from sessions , (select count(*)total_sessions from sessions)sess
   group by node_name,sess.total_sessions
)
sess_tab
order by 3 desc;




--High CPU Usage more than a %
\!echo "High CPU Usage more than a %############################################################################################"
select 
node_name,
sysdate,
start_time,
end_time,
to_char(sysdate - end_time,'YYYY-MM-DD HH24:MI:SS')time_ago,
average_cpu_usage_percent
from v_monitor.cpu_usage where start_time between (current_timestamp - interval '10 minutes') and sysdate()
and average_cpu_usage_percent > 50 order by start_time desc;




--IO_USAGE (12 Hours seems to be the Max on STG)
\!echo "IO_USAGE################################################################################################################"
SELECT 
        NODE_NAME, 
        round(SUM(READ_KBYTES_PER_SEC)/1024^2,3) GB_TOTAL_READ_PER_SEC, 
        round(SUM(WRITTEN_KBYTES_PER_SEC)/1024^2,3) GB_TOTAL_WRITTEN_PER_SEC 
FROM io_usage 
WHERE start_time between (current_timestamp - interval '12 hours') and sysdate()
GROUP BY NODE_NAME
ORDER BY NODE_NAME;

