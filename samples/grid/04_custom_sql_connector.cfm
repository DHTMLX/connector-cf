<cfinclude template="../config.cfm">

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.sql.attach("delete","update grid50000 set item_nm='deleted' where item_id={item_id}")>
<cfset grid.dynamic_loading(100)>
<cfset grid.render_table("grid50000","item_id","item_nm,item_cd")>

