\timing
--Queries de performance
\!echo "Select sysdate from dual;#####################################################################################################"
select sysdate from dual;


--GET_AHM_TIME
\!echo "GET_AHM_TIME##########################################################################################################"
select sysdate, min(epoch_close_time at time zone 'utc')min_epoch, to_char(sysdate-min(epoch_close_time at time zone 'utc'),'yyyy-mm-dd hh24:mi:ss')time_ago from epochs;
\!echo "If TIME_AGO is higher than 1 hour, consider run SELECT MAKE_AHM_NOW();"

--Nodes status
\!echo "Nodes not in UP status############################################################################################################"
select node_name, node_state, node_address, export_address, catalog_path from nodes where node_state<>'UP';


-- /* --Top offender
-- \!echo "Top offender############################################################################################################"
-- select
-- user_name,
-- session_id,
-- statement_start,
-- sum_memory_in_use_gb,
-- sum_thread_count,
-- left(REGEXP_REPLACE(current_statement,'[\r\t\f\n]',' '),80)||'...' short_current_statement,
-- REGEXP_REPLACE(current_statement,'[\r\t\f\n]',' ')
-- from sessions a,
-- (
   -- select
   -- transaction_id,
   -- statement_id,
   -- round(sum(memory_inuse_kb)/(1024^2),2) sum_memory_in_use_gb,
   -- sum(thread_count) sum_thread_count
   -- from resource_acquisitions
   -- where is_executing = 'true'
   -- group by 1,2
-- )
-- subn
-- where a.transaction_id = subn.transaction_id
-- and a.statement_id = subn.statement_id
-- and statement_start > current_timestamp - interval '12 hours'
-- and current_statement not ilike '%direct%' --Comentado para no buscar el hint "Direct"
-- order by sum_memory_in_use_gb desc;


-- --Percentage of sessions per node
-- \!echo "Percentage of sessions per node#########################################################################################"
-- select
	-- node_name,
	-- Sessions_per_node,
	-- to_char(round((Sessions_per_node/total_sessions)*100,2),'999,999,999,999,999.999') Percent_sessions
-- from
-- (
   -- select
      -- node_name, 
      -- count(*) Sessions_per_node, 
      -- sess.total_sessions
   -- from sessions , (select count(*)total_sessions from sessions)sess
   -- group by node_name,sess.total_sessions
-- )
-- sess_tab
-- order by 3 desc;


-- --Locks
-- \!echo "Locks###################################################################################################################"
-- select
-- --node_names,
-- object_name,
-- --object_id,
-- (select user_name from sessions where transaction_id = lks.transaction_id) transaction_user,
-- lock_mode,
-- decode (lock_mode,
-- 'S','Shared',
-- 'I','Insert',
-- 'SI','SharedInsert',
-- 'X','Exclusive',
-- 'T','Tuple Mover',
-- 'U','Usage',
-- 'O','Owner',
-- 'NONE')
-- lock_scope,
-- request_timestamp,
-- grant_timestamp,
-- left(REGEXP_REPLACE(transaction_description,'[\r\t\f\n]',' '),120)||'...' short_transaction_description,
-- qr.transaction_id,
-- user_name, session_id, success, is_executing
-- from locks lks, query_requests qr
-- where lks.transaction_id = qr.transaction_id
-- and is_executing = true;



-- --Lock count
-- \!echo "Lock count##############################################################################################################"
-- select
-- object_name,
-- decode (lock_mode,'S','Shared','I','Insert','SI','SharedInsert','X','Exclusive','T','Tuple Mover','U','Usage','O','Owner','NONE'),
-- lock_scope,
-- Count(*)
-- from locks
-- group by object_name,lock_mode,lock_scope
-- order by 1;



-- --Lock usage
-- \!echo "lock usage##############################################################################################################"
-- --Lock usage
-- Select
-- session_id, 
-- (select user_name from sessions where session_id = LUS.session_id)user_name,
-- object_name,
-- mode_scope,
-- avg_hold_time,
-- max_hold_time,
-- hold_count,
-- avg_wait_time,
-- max_wait_time,
-- wait_count
-- from (
-- select
-- --node_name,
-- session_id,
-- object_name,
-- --mode,
-- decode (mode,
-- 'S','Shared',
-- 'I','Insert',
-- 'SI','SharedInsert',
-- 'X','Exclusive',
-- 'T','Tuple Mover',
-- 'U','Usage',
-- 'O','Owner',
-- 'NONE') mode_scope,
-- to_char(avg(avg_hold_time))avg_hold_time,
-- to_char(avg(max_hold_time))max_hold_time,
-- sum(hold_count)hold_count,
-- to_char(avg(avg_wait_time))avg_wait_time,
-- to_char(avg(max_wait_time))max_wait_time,
-- sum(wait_count)wait_count
-- from lock_usage LU
-- where 
-- wait_count > 0
-- and Session_id in (select session_id from sessions)
-- group by 
-- session_id,
-- object_name,
-- mode_scope) LUS
-- order by LUS.session_id, LUS.max_wait_time desc;



-- --Total & inactive sessions
-- \!echo "Total & inactive sessions###############################################################################################"
-- select 
-- (Select 'Total sessions: '||count(*) from sessions) Total, 
-- (Select 'Active sessions without transactions: '||count(*) from sessions where transaction_id <> -1) Inactive
-- from dual;


-- --Check load balancing
-- \!echo "Check load balancing####################################################################################################"
-- SELECT a.node_name, 
       -- a.requests, 
       -- ROUND((a.requests / b.total_requests) * 100, 2.0) AS percent
-- FROM   (SELECT node_name, 
               -- COUNT(*) AS requests 
        -- FROM   v_monitor.query_requests 
        -- GROUP  BY node_name) a 
       -- CROSS JOIN (SELECT COUNT(*) AS total_requests 
                   -- FROM   v_monitor.query_requests) b 
-- ORDER  BY percent DESC;


-- --Tables to Purge
-- \!echo "Tables to Purge#########################################################################################################"
-- /*
-- select 
-- t1.schema_name, 
-- t2.anchor_table_name,  
-- to_char(sum(deleted_row_count),'999,999,999,999,999,999') sum_del_rows, 
-- to_char(sum(used_bytes)/1024^2,'999,999,999,999,999,999.999')  sum_del_mb,
-- 'select PURGE_TABLE(''' || t1.schema_name || '.' || anchor_table_name || '''); select do_tm_task(''mergeout'','''|| t1.schema_name || '.' || anchor_table_name || ''');' as command_to_run
-- from delete_vectors t1,
-- projections t2
-- where t1.schema_name = t2.projection_schema
-- and t1.projection_name = t2.projection_name
-- group by 1,2,5
-- order by 4 desc;
-- */

-- --Current Node Resources (Processes & Memory)
-- \!echo "Current Node Resources (Processes & Memory)#############################################################################"
-- select 
-- node_name,
-- round(process_size_bytes/(1024^3),2)process_size_GB,
-- round(process_resident_set_size_bytes/(1024^3),2)process_resident_set_size_GB,
-- round(process_shared_memory_size_bytes/(1024^2),2)process_shared_memory_size_MB,
-- round(process_text_memory_size_bytes/(1024^2),2)process_text_memory_size_MB,
-- round(process_data_memory_size_bytes/(1024^3),2)process_data_memory_size_GB,
-- round(process_library_memory_size_bytes/(1024^3),2)process_library_memory_size_GB,
-- round(process_dirty_memory_size_bytes/(1024^3),2)process_dirty_memory_size_GB
-- from v_monitor.node_resources;


-- --High CPU Usage more than a %
-- \!echo "High CPU Usage more than a %############################################################################################"
-- select 
-- node_name,
-- sysdate,
-- start_time,
-- end_time,
-- to_char(sysdate - end_time,'YYYY-MM-DD HH24:MI:SS')time_ago,
-- average_cpu_usage_percent
-- from v_monitor.cpu_usage where start_time between (current_timestamp - interval '10 minutes') and sysdate()
-- and average_cpu_usage_percent > 50 order by start_time desc;


-- --IO_USAGE
-- \!echo "IO_USAGE################################################################################################################"
-- SELECT 
        -- NODE_NAME, 
        -- round(SUM(READ_KBYTES_PER_SEC)/1024^2,3) GB_TOTAL_READ_PER_SEC, 
        -- round(SUM(WRITTEN_KBYTES_PER_SEC)/1024^2,3) GB_TOTAL_WRITTEN_PER_SEC 
-- FROM io_usage 
-- WHERE start_time between (current_timestamp - interval '12 hours') and sysdate()
-- GROUP BY NODE_NAME
-- ORDER BY NODE_NAME;


-- --Long running queries
-- \!echo "Long running queries####################################################################################################"
-- SELECT qr.node_name, 
       -- qr.user_name, 
       -- qr.request_type, 
       -- to_char(round(qr.request_duration_ms/1000,3),'999,999,999,999,999.999')request_duration_s, 
       -- to_char(round((qr.request_duration_ms/1000)/60,3),'999,999,999,999,999.999')request_duration_m, 
       -- qr.is_executing,
	   -- case 
           -- when length(qr.request)>=80 then LEFT(REGEXP_REPLACE(qr.request,'[\r\t\f\n]',' '), 80)||'...' 
           -- else REGEXP_REPLACE(qr.request,'[\r\t\f\n]',' ')
	   -- end short_request,
       -- qr.success, 
       -- qr.error_count, 
       -- qr.start_timestamp, 
       -- qr.end_timestamp,
       -- qr.session_id, 
       -- qr.transaction_id
       -- --request
-- FROM   v_monitor.query_requests as qr
-- where 
-- qr.start_timestamp between (sysdate - interval '6 hours') and sysdate
-- --qr.end_timestamp between (sysdate - interval '6 hours') and sysdate
-- ORDER  BY qr.request_duration_ms desc limit 100;


-- --system_resource_usage by node
-- \!echo "System Resource Usage by node#########################################################################################################"
-- Select 
-- node_name,
-- End_time,
-- round(avg(average_memory_usage_percent),2) "average_memory_usage_percent",
-- round(avg(average_cpu_usage_percent),2) average_cpu_usage_percent,
-- round(avg(net_rx_MB_per_second),2) avg_net_rx_MB_per_second,
-- round(avg(net_tx_MB_per_second),2) avg_net_tx_MB_per_second,
-- round(avg(io_read_MB_per_second),2) avg_io_read_MB_per_second,
-- round(avg(io_written_MB_per_second),2) avg_io_written_MB_per_second
-- from (
-- Select
-- node_name,
-- left(to_char(end_time,'YYYY-MM-DD HH24:MI'),length(to_char(end_time,'YYYY-MM-DD HH24:MI'))-1)||'0' "End_time",
-- average_memory_usage_percent,
-- average_cpu_usage_percent,
-- to_char(net_rx_kbytes_per_second/1024,'999,999,999,999.999')net_rx_MB_per_second,
-- to_char(net_tx_kbytes_per_second/1024,'999,999,999,999.999')net_tx_MB_per_second,
-- to_char(io_read_kbytes_per_second/1024,'999,999,999,999.999')io_read_MB_per_second,
-- to_char(io_written_kbytes_per_second/1024,'999,999,999,999.999')io_written_MB_per_second
-- from system_resource_usage
-- where
-- "End_time" between (current_timestamp - interval '10 minutes') and sysdate
-- ) X
-- group by node_name, "End_time"
-- order by "End_time",node_name;

-- SELECT * FROM "EGIG_CORE_APP_BM_SERVICE_DELIVERY".BMT_AME_SUBK_NONEVENT;
-- select Max(BMT_AME_SUBK_NONEVENT_KY) from "EGIG_CORE_APP_BM_SERVICE_DELIVERY".BMT_AME_SUBK_NONEVENT; */