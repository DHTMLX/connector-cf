<cfcomponent namespace="FormDataItem" extends="DataItem" hint="DataItem class for dhtmlxForm component">
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
		<cfset local.str="">
		<cfloop from="1" to="#ArrayLen(variables.config.data)#" index="local.i">
			<cfset local.tag = variables.config.data[local.i]['db_name']>
			<cfset local.str = local.str & "<" & local.tag & "><![CDATA[" & variables.data[local.tag] & "]]></" & local.tag & ">">
		</cfloop>
		<cfreturn local.str>
	</cffunction>
</cfcomponent>
	