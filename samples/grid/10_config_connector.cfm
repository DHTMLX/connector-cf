<cfinclude template="../config.cfm">

<cffunction name="grid_header">
	<cfargument name="connector" type="any" hint="Grid Connector Object">
	<cfargument name="out" type="any" hint="Output Writer">
	<cfset var header = "">
	<cfif not isDefined("URL.posStart")>
		<cfsavecontent variable="header">
		<cfoutput>
			<head>
				<column width="50" type="ed" align="right" color="white" sort="na">Sales</column>
				<column width="150" type="ed" align="left" color="##d5f1ff" sort="na">Book Title</column>
				<column width="100" type="ed" align="left" color="##d5f1ff" sort="na">Author</column>
			</head>
		</cfoutput>	
		</cfsavecontent>
		<cfset ARGUMENTS.out.add(header)>
	</cfif>		
</cffunction>
<cfset grid = createObject("component",request.dhtmlxConnectors["grid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset grid.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset grid.dynamic_loading(100)>
<cfset grid.event.attach("beforeOutput",grid_header)>
<cfset grid.render_table("grid50000","item_id","item_id,item_nm,item_cd")>
