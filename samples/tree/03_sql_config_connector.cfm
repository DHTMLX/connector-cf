<cfinclude template="../config.cfm">
<cfset tree = createObject("component",request.dhtmlxConnectors["tree"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.dynamic_loading(true)>
<cfset tree.render_sql("SELECT taskId,taskName from tasks WHERE complete>49","taskId","taskName","","parentId")>
