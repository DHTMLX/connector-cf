<cfinclude template="../config.cfm">

<cffunction name="color_rows">
	<cfargument name="row">
	<cfif ARGUMENTS.row.get_index() mod 2>
		<cfset ARGUMENTS.row.set_row_color("red")>	
	</cfif>		
</cffunction>

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>
<cfset grid.event.attach("beforeRender",color_rows)>
<cfset grid.render_table("grid50000","item_id","item_nm,item_cd")>
