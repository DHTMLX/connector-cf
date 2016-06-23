<cfinclude template="../config.cfm">
<cfset tree = createObject("component",request.dhtmlxConnectors["treegrid_group"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.render_table("products2", "id", "product_name,scales,colour", "", "category")>
