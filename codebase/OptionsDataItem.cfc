<cfcomponent namespace="OptionsDataItem" extends="DataItem" hint="DataItem class for dhxForm:options">
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
		<cfset local.str ="">
		<cfset local.str = local.str & '<item value="' & variables.data[variables.config.data[1]['db_name']] & '" label="' & variables.data[variables.config.data[2]['db_name']] & '"/>'>
		<cfreturn local.str>
	</cffunction>
</cfcomponent>
	