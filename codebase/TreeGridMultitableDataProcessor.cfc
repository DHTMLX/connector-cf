<cfcomponent namespace="TreeGridMultitableDataProcessor" extends="DataProcessor" hint="DataProcessor class for Grid component">
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="connector" type="any" required="yes">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="_request" type="any" required="yes">	
		<cfset super.init(ARGUMENTS.connector,ARGUMENTS.config,ARGUMENTS._request)>
		<cfreturn this>
	</cffunction>

	<cffunction name="name_data" access="public" returntype="string" hint="convert incoming data name to valid db name. Converts c0..cN to valid field names. Return related db_name">
		<cfargument name="data" type="string" required="yes" hint="data name from incoming request">
		<cfset var local = structNew()>
		<cfif ARGUMENTS.data eq "gr_pid">
			<cfreturn variables.config.relation_id["name"]>
		</cfif>	
		<cfset local.match = refindNoCase("c([\d]+)$", ARGUMENTS.data,1,true)>
		<cfset local.data_num = mid(ARGUMENTS.data,local.match.pos[2],local.match.len[2])>
		<cfif structKeyExists(variables.config.data,local.data_num)>
			<cfreturn variables.config.data[local.data_num]["db_name"]>
		</cfif>
		<cfreturn ARGUMENTS.data>
	</cffunction>
	
	<cffunction name="first_loop_form_fields" returntype="string" hint="Get the list from the function 'name_data'">
		<Cfreturn "gr_pid">
	</cffunction>
</cfcomponent>
