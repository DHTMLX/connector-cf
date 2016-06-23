<cfinclude template="../config.cfm">

<cfset tree = createObject("component",request.dhtmlxConnectors["treegrid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.render_sql("SELECT * from tasks WHERE complete>49","taskId","taskName,duration,complete","","parentId")>

