<cfinclude template="../config.cfm">
<cfset tree = createObject("component",request.dhtmlxConnectors["tree_group"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.render_table("products2","id","product_name","","category")>
