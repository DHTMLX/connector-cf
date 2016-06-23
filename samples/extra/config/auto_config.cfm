<cfinclude template="../../config.cfm">
<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<cfset grid.render_table("grid50")>
