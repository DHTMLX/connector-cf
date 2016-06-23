<cfinclude template="../config.cfm">
<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init("c:/","FileSystem")>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.render_table("../","safe_name","filename,full_filename,size,name,extention,date,is_folder")>