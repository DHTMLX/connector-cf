<cfinclude template="../../config.cfm">

<cffunction name="delete_related">
	<cfargument name="action" type="any" required="yes">
	<cfset var local  = structNew()>
	<cfset local.status = ARGUMENTS.action.get_status()>
	<cfset local.type = ARGUMENTs.action.get_value("rec_type")>
	<cfset local.pid = ARGUMENTS.action.get_value("event_pid")>
	<!--- when serie changed or deleted we need to remove all linked events --->
	<cfif (local.status eq "deleted" OR local.status eq "updated") AND local.type neq "">
		<cfset request.scheduler.sql.query("DELETE FROM events_rec WHERE event_pid=" & request.scheduler.sql.escape(ARGUMENTS.action.get_id(),"event_pid"))>
	</cfif>
	<cfif local.status eq "deleted" AND local.pid neq 0>
		<cfset request.scheduler.sql.query("UPDATE events_rec SET rec_type='none' WHERE event_id=" & request.scheduler.sql.escape(ARGUMENTS.action.get_id(),"event_pid"))>
		<cfset ARGUMENTS.action.success()>
	</cfif>
</cffunction>


<cffunction name="insert_related">
	<cfargument name="action" type="any" required="yes">
	<cfset var local  = structNew()>
	<cfset local.status = ARGUMENTS.action.get_status()>
	<cfset local.type = ARGUMENTS.action.get_value("rec_type")>
	<cfif local.status eq "inserted" AND local.type eq "none">
		<cfset ARGUMENTS.action.set_status("deleted")>
	</cfif>	
</cffunction>

<cfset request.scheduler = createObject("component",request.dhtmlxConnectors["scheduler"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset request.scheduler.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset request.scheduler.event.attach("beforeProcessing",delete_related)>
<cfset request.scheduler.event.attach("afterProcessing",insert_related)>
<cfset request.scheduler.render_table("events_rec","event_id","start_date,end_date,text,rec_type,event_pid,event_length")>

