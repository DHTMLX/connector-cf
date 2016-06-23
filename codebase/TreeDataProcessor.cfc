<cfcomponent namespace="TreeDataProcessor" extends="DataProcessor">
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="connector" type="any" required="yes">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="_request" type="any" required="yes">	
		<cfset super.init(ARGUMENTS.connector,ARGUMENTS.config,ARGUMENTS._request)>
		<cfset ARGUMENTS._request.set_relation("")>
		<cfreturn this>
	</cffunction>

	<cffunction name="name_data" access="public" returntype="string" hint="convert incoming data name to valid db name. Converts c0..cN to valid field names. Return related db_name">
		<cfargument name="data" type="string" required="yes" hint="data name from incoming request">
		<cfif ARGUMENTS.data eq "tr_pid">
			<cfreturn variables.config.relation_id["db_name"]>
		</cfif>
		<cfif ARGUMENTS.data eq "tr_text">
			<cfreturn variables.config.text[1]["db_name"]>
		</cfif>
		<cfreturn ARGUMENTS.data>
	</cffunction>
	<cffunction name="first_loop_form_fields" returntype="string" hint="Get the list from the function 'name_data'">
		<Cfreturn "tr_pid,tr_text">
	</cffunction>
</cfcomponent>		
