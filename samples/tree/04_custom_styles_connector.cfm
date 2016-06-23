<cfinclude template="../config.cfm">
<cfset tree = createObject("component",request.dhtmlxConnectors["tree"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cffunction name="custom_format">
	<cfargument name="item" type="any" required="yes">
	<cfif ARGUMENTS.item.get_value("duration") gt 10>
		<cfset ARGUMENTS.item.set_image("lock.gif")>
	</cfif>			
	<cfif ARGUMENTS.item.get_value("complete") gt 75>
		<cfset ARGUMENTS.item.set_check_state(1)>
	</cfif>			
</cffunction>
<cfset tree.event.attach("beforeRender",custom_format)>
<cfset tree.render_sql("SELECT taskId,taskName,duration,complete from tasks WHERE complete>49","taskId","taskName","","parentId")>
