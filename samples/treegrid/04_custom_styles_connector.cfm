<cfinclude template="../config.cfm">

<cffunction name="custom_format">
	<cfargument name="item">
	<cfset var cl = "">
	<cfif ARGUMENTS.item.get_value("complete")lt 75>
		<cfset cl = "##AAFFFF">
	<cfelse>
		<cfset cl = "##FFAAFF">	
	</cfif>
	<cfset ARGUMENTS.item.set_row_color(cl)>
	<cfif ARGUMENTs.item.get_value("duration") gt 10>
		<cfset ARGUMENTS.item.set_image("true.gif")>
	<cfelse>
		<cfset ARGUMENTS.item.set_image("false.gif")>
	</cfif>			
</cffunction>

<cfset tree = createObject("component",request.dhtmlxConnectors["treegrid"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.event.attach("beforeRender",custom_format)>
<cfset tree.render_sql("SELECT * from tasks WHERE complete>49","taskId","taskName,duration,complete","","parentId")>

