<cfinclude template="../config.cfm">
<cfset data = createObject("component",request.dhtmlxConnectors["dataview"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<cfset data.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
<!---
<cfset data.field_types("start:date")>
--->
<cfset data.enable_live_update('actions_table')>
<cfset data.render_table("tasks","taskId","taskName,duration,start")>
