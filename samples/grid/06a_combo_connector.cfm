<cfinclude template="../config.cfm">

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>

<cfset ar = ArrayNew(1)>
<cfset ar[1] = "1">
<cfset ar[2] = "two">
<cfset ar[3] = "3">
<cfset grid.set_options("item_nm",ar)>
<cfset ar = structNew()>
<cfset ar["91"] = "one">
<cfset ar["75"] = "two">
<cfset grid.set_options("item_cd",ar)>

<cfset grid.sql.set_transaction_mode("record")>
<cfset grid.render_table("grid50","item_id","item_nm,item_cd")>
