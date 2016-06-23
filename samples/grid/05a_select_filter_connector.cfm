<cfinclude template="../config.cfm">

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>

<cfset filter1 = createObject("component",request.dhtmlxConnectors["options"]).init(request.dhtmlxConnectors["datasource"])>
<cfset filter1.render_sql("SELECT  DISTINCT SUBSTRING(item_nm,1,2) as value from grid50","item_id","item_nm(value)")>
<cfset grid.set_options("item_nm",filter1)>
<cfset grid.render_table("grid50","item_id","item_nm,item_cd")>


