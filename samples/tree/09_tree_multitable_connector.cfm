<cfinclude template="../config.cfm">
<cfset tree = createObject("component",request.dhtmlxConnectors["tree_multitable"]).init(request.dhtmlxConnectors["datasource"],request.dhtmlxConnectors["db_type"])>
<!---
<cfset tree.enable_log(variables,getCurrentTemplatePath() & "_debug.log")>
--->
<cfset tree.setMaxLevel(3)>
<cfset level = tree.get_level()>
<cfswitch expression="#level#">
	<cfcase value="0">
		<cfset tree.render_table("projects2","project_id","project_name","","")>
	</cfcase>
	<cfcase value="1">
		<cfset tree.render_sql("SELECT teams2.team_id, teams2.team_name, project_team2.project_id FROM teams2 INNER JOIN project_team2 ON teams2.team_id=project_team2.team_id", "team_id", "team_name", "", "project_id")>
	</cfcase>
	<cfcase value="2">
		<cfset tree.render_table("developers2", "developer_id", "developer_name", "", "developer_team")>
	</cfcase>
	<cfcase value="3">
		<cfset tree.render_table("phones2", "phone_id", "phone", "", "phone_developer")>
	</cfcase>
</cfswitch>

