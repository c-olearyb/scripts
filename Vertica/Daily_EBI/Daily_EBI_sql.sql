\timing
--Get Sysdate
\!echo "Print System Date;#####################################################################################################"
select sysdate from dual;


--Canary Query
\!echo "Canary Query;#####################################################################################################"
select * from databases;


--Node Status
\!echo "Check Nodes Status;#####################################################################################################"
select * from nodes;


--Nodes !UP
\!echo "Nodes not in UP status############################################################################################################"
select node_name, node_state, node_address, export_address, catalog_path from nodes where node_state<>'UP';


--AHM Time
\!echo "Get Current AHM Time;#####################################################################################################"
\!echo "If TIME_AGO is higher than 1 hour, consider run SELECT MAKE_AHM_NOW();"
SELECT GET_AHM_TIME();
select sysdate, min(epoch_close_time at time zone 'utc')min_epoch, to_char(sysdate-min(epoch_close_time at time zone 'utc'),'yyyy-mm-dd hh24:mi:ss')time_ago from epochs;



--Unrefreshed Projections
\!echo "Validate Unrefresehd Projections##########################################################################################################"
\!echo "If return=0 then projections are refreshed"
select projection_schema, anchor_table_name, projection_name from projections where is_up_to_date = 'f';

--Check downtimes for the past 24 hours 
\!echo "Check downtimes from the last 24 hours##########################################################################################################"
Select
event_timestamp,
to_char(sysdate - event_timestamp,'YYYY-MM-DD HH24:MI') Time_ago,
node_name,node_state
from v_monitor.node_states
where event_timestamp between (sysdate() - INTERVAL '1 DAY') and sysdate()
order by event_timestamp desc;


