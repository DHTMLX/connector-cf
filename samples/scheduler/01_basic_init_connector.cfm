<cfinclude template="../config.cfm">
<cfset scheduler = createObject("component",request.dhtmlxConnectors["scheduler"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset scheduler.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset scheduler.render_table("events","event_id","start_date,end_date,event_name,details")>
