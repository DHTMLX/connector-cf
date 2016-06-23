<!---
<cffunction name="validate">
	<cfargument name="data">
    <cfif len(ARGUMENTS.data.get_value("taskName")) gt 2>
           <cfset ARGUMENTS.data.invalid()>
    </cfif>
</cffunction>

<cfset request.grid = createObject("component","dhtmlxConnectors.GridConnector").init("sampleDB","MySQL")>
<cfset request.grid.event.attach("beforeUpdate",validate)>
<cfset request.grid.enable_log(variables,"debug.txt")>
<cfset request.grid.render_table("tasks","taskID","taskName,duration")>
--->

<!---
<cfset grid = createObject("component","dhtmlxConnectors.GridConnector").init("","FileSystem")>
<cfset grid.render_table("../","safe_name","filename,full_filename,size,name,extention,date,is_folder")>
--->

<!---

<cfinclude template="../config.cfm">
<cfset grid = createObject("component","dhtmlxConnectors.GridConnector").init("sampleDB","MySQL")>
<cfset config = createObject("component","dhtmlxConnectors.GridConfiguration").init("sampleDB","MySQL")>
 
     <cfset config.setHeader("Item,##cspan")>
     <cfset config.attachHeader("Item Name,Item CD")>
	 
	 <cfset config.attachFooter("Item Name,Item CD", "background: ##ff0000;,background: ##00ff00;")>
	 <cfset config.attachFooter("Item Name Test,##rspan", "background: ##0000ff;color:white;")>

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
<cfset grid.render_table("grid50","item_id","item_nm,item_cd")>

--->
<!---
<cffunction name="formatting"> 
	<cfargument name="row">
        <!--- set row color --->
	<cfset ARGUMENTS.row.set_row_color("##" & ARGUMENTS.row.get_value("item_cd"))>
     <!--- save in userdata --->
     <cfset ARGUMENTS.row.set_userdata("some_data",ARGUMENTS.row.get_value("item_cd"))>
</cffunction>
<cfset grid = CreateObject("component","dhtmlxConnectors.GridConnector").init("sampleDB","MySQL")>
<cfset grid.event.attach("beforeRender",formatting)>
<cfset grid.enable_log(variables,"D:\dhtmlXConnectors\main\cfm\codebase\debug.txt")>
<cfset grid.dynamic_loading(100)>
<cfset grid.render_table("countries","item_id","item_nm","item_cd")>

--->

<cfset request.grid = createObject("component","dhtmlxConnectors.GridConnector").init("sampleDB","MySQL")>
<cfset request.grid.sql.set_transaction_mode("record")>
<cfset request.grid.enable_log(variables,expandPath("debug.txt"))>
<cfset request.grid.render_table("tasks","taskID","taskName,duration")>