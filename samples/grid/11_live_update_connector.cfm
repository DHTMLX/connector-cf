<cfinclude template="../config.cfm">
<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.enable_live_update('actions_table')>
<cfset grid.render_table("grid50","item_id","item_nm,item_cd")>
