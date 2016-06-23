<cfinclude template="../config.cfm">

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>

<cfset filter1 = createObject("component",request.dhtmlxConnectors["options"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<cfset filter1.render_table("countries","item_id","item_id(value),item_nm(label)")>
<cfset grid.set_options("item_nm",filter1)>
<cfset grid.render_table("grid50","item_id","item_nm,item_cd")>
