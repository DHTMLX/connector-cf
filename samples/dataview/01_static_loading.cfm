<cfinclude template="../config.cfm">
<cfset data = createObject("component",request.dhtmlxConnectors["dataview"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset data.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset data.render_sql(" SELECT id,Package,Version,Maintainer FROM packages_plain WHERE Id < 1000","Id","Package,Version,Maintainer")>
