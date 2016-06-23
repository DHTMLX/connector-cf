<cfinclude template="../config.cfm">

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>
<cfset grid.render_sql("SELECT grid50000.item_id as ID, grid50000.item_nm FROM grid50000","item_id(ID)","grid50000.item_id(ID),item_nm")>

