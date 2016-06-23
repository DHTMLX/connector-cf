<cfinclude template="../config.cfm">
<cfset combo = createObject("component",request.dhtmlxConnectors["combo"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset combo.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset combo.render_table("country_data","country_id","name")>
