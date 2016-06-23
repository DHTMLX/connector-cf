<cfinclude template="../config.cfm">
<cfset data = createObject("component",request.dhtmlxConnectors["dataview"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset data.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset data.dynamic_loading(50)>
<cfset data.render_sql(" SELECT * FROM packages_plain WHERE Id < 1000","Id","Package,Version,Maintainer")>
