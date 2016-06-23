<cfcomponent namespace="SchedulerDataItem" extends="DataItem" hint="DataItem class for Scheduler component">
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="data" type="any" required="yes" hint="Data object">
		<cfargument name="config" type="any" required="yes" hint="Config object">
		<cfargument name="index" type="numeric" required="no" default="1" hint="Index of an element">
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfreturn this>
	</cffunction>

	<cffunction name="to_xml" access="public" returntype="string">
		<cfset var local = structNew()>
		<cfif variables.skip>
			<cfreturn "">
		</cfif>	
		
		<cfset local.str="<event id='" & get_id() & "' >">
		<cfset local.str = local.str & "<start_date><![CDATA[" & variables.data[variables.config.text[1]["name"]] & "]]></start_date>">
		<cfset local.str = local.str & "<end_date><![CDATA[" & variables.data[variables.config.text[2]["name"]] & "]]></end_date>">
		<cfset local.str = local.str & "<text><![CDATA[" & variables.data[variables.config.text[3]["name"]] & "]]></text>">
		<cfloop from="4" to="#ArrayLen(variables.config.text)#" index="local.i">
			<cfset local.extra = variables.config.text[local.i]["name"]>
			<cfset local.str = local.str & "<" & local.extra & "><![CDATA[" & variables.data[local.extra] & "]]></" & local.extra & ">">
		</cfloop>
		<cfreturn local.str & "</event>">
	</cffunction>
</cfcomponent>
	