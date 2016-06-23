<cfinclude template="../config.cfm">
<cfset combo = createObject("component",request.dhtmlxConnectors["combo"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset combo.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset combo.render_sql("SELECT country_id,name FROM country_data  WHERE country_id >40 ","country_id","name")>
