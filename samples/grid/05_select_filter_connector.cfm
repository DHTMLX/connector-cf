<cfinclude template="../config.cfm">

<cffunction name="change_filter">
	<cfargument name="set">
	<cfset var local = structNew()>
	<cfset local.ind = ARGUMENTS.set.index("item_ch")>
	<cfif local.ind>
		<cfif ARGUMENTS.set.rules[local.ind]["value"] eq "checked">
			<cfset local.v = 1>
		<cfelseif ARGUMENTS.set.rules[local.ind]["value"] eq "unchecked">
			<cfset local.v = 0>	
		<cfelse>	
			<cfset local.v = "">	
		</cfif>
		<cfset ARGUMENTS.set.rules[local.ind]["value"]=local.v>
	</cfif>
</cffunction>

<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>
<cfset grid.event.attach("beforeFilter",change_filter)>

<cfset st = structNew()>
<cfset st["checked"] = true>
<cfset st["unchecked"] = true>
<cfset grid.set_options("item_ch",st)>

<cfset grid.render_table("countries","item_id","item_nm,item_cd,item_ch")>
