<cfinclude template="../config.cfm">
<cfset list = createObject("component",request.dhtmlxConnectors["options"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset list.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset list.render_table("types","typeid","typeid(value),name(label)")>

<cfset scheduler = createObject("component",request.dhtmlxConnectors["scheduler"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset scheduler.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset scheduler.set_options("type", list)>
<cfset scheduler.render_table("tevents","event_id","start_date,end_date,event_name,type")>

