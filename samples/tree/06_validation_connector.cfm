<cfinclude template="../config.cfm">
<cfset tree = createObject("component",request.dhtmlxConnectors["tree"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cffunction name="my_check">
	<cfargument name="action" type="any" required="yes">
	<cfif Len(ARGUMENTS.action.get_value("taskName")) lt 5>
		<cfset ARGUMENTS.action.invalid()>
	</cfif>			
</cffunction>
<cfset tree.event.attach("beforeProcessing",my_check)>
<cfset tree.render_table("tasks","taskId","taskName","","parentId")>
