<cfinclude template="../config.cfm">

<cffunction name="check_data">
	<cfargument name="action">
	<cfif ARGUMENTS.action.get_value("item_cd") eq "" OR ARGUMENTS.action.get_value("item_nm") eq "">
		<cfset ARGUMENTS.action.invalid()>
	</cfif>		
</cffunction>

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>
<cfset grid.event.attach("beforeProcessing",check_data)>
<cfset grid.render_table("grid50000","item_id","item_nm,item_cd")>
