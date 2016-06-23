<cfinclude template="../config.cfm">
<cfset tree = createObject("component",request.dhtmlxConnectors["tree"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.dynamic_loading(10)>
<cfset tree.render_table("tasks","taskId","taskName","","parentId")>
