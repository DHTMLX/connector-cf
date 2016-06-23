<cfinclude template="../../config.cfm">
<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<cfset config = createObject("component",request.dhtmlxConnectors["grid_config"]).init(true)>
<cfset grid.set_config(config)>
<cfset grid.render_table("grid50")>
