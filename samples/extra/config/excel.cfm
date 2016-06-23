<cfinclude template="../../config.cfm">

<cfset convert = createObject("component",request.dhtmlxConnectors["convert"]).init("http://192.168.1.16/dhtmlxdev/ExportTools/grid2Excel/generate.php",expandPath("test.xls"),true)>
<cfset convert.excel()>

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<cfset config = createObject("component",request.dhtmlxConnectors["grid_config"]).init(true)>
<cfset grid.set_config(config)>
<cfset grid.render_table("grid50")>
