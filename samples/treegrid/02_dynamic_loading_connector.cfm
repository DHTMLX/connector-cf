<cfinclude template="../config.cfm">

<cfset tree = createObject("component",request.dhtmlxConnectors["treegrid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.dynamic_loading(true)>
<cfset tree.render_table("tasks","taskId","taskName,duration,complete","","parentId")>

