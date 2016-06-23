<cfcomponent namespace="DistinctOptionsConnector" extends="OptionsConnector">
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="res" type="any" required="yes">
		<cfargument name="type" type="string" required="no" default="">
		<cfargument name="item_type" type="string" required="no" default="">
		<cfargument name="data_type" type="string" required="no" default="">
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="render" access="public" returntype="any" hint="render self, process commands, return data as XML, not output data to stdout, ignore parameters in incoming request. Return: data as XML string">
		<Cfset var local= structNew()>
		<cfif NOT variables.init_flag>
			<cfset variables.init_flag=true>
			<cfreturn "">
		</cfif>
		<cfset local.res = this.sql.get_variants(variables.config.text[1]["db_name"],variables._request)>
		<cfreturn render_set(local.res)>	
	</cffunction>
</cfcomponent>
