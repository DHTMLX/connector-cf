<cfinclude template="../config.cfm">
<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->


<cfset config = createObject("component",request.dhtmlxConnectors["grid_config"]).init()>
<!---
<cfset config.setHeader("Item Name,Item CD")>
<cfset config.attachHeader("Item Name Test,##rspan")>
<cfset ar = ArrayNew(1)>
<cfset ArrayAppend(ar,"background-color: ##ff0000;")>
<cfset ArrayAppend(ar,"background-color: ##00ff00;")>
<cfset config.attachFooter("Item Name,Item CD", ar)>
<cfset config.attachFooter("Item Name Test,##rspan", "background-color: ##0000ff;color:white;")>
<cfset config.setColIds("col1,col2")>
<cfset config.setInitWidths('120,*')>
<cfset config.setColSorting("connector,connector")>
<cfset config.setColColor(",##dddddd")>
<cfset config.setColHidden("false,false")>
<cfset config.setColTypes("ro,ed")>
<cfset config.setColAlign('center,center')>
<cfset config.setColVAlign('bottom,middle')>
--->
<cfset config.setHeader("Item,##cspan")>
<cfset config.attachHeader("Item Name,Item CD")>
<cfset config.setColIds("col1,col2")>
<cfset config.setInitWidths('120,*')>
<cfset config.setColSorting("connector,connector")>
<cfset config.setColColor(",##dddddd")>
<cfset config.setColHidden("false,false")>
<cfset config.setColTypes("ro,ed")>
<cfset config.setColAlign('center,center')>
<cfset config.setColVAlign('bottom,middle')>
<cfset grid.set_config(config)>
	
<cfset grid.dynamic_loading(100)>
<cfset grid.render_table("grid50000","item_id","item_nm,item_cd")>
