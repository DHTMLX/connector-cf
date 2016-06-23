<cfcomponent namespace="KeyGridDataProcessor" extends="GridDataProcessor" hint="DataProcessor class for Grid component">
	<!--- 
		convert incoming data name to valid db name
		converts c0..cN to valid field names
		@param data 
			data name from incoming request
		@return 
			related db_name
	--->
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="connector" type="any" required="yes">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="_request" type="any" required="yes">	
		<cfset super.init(ARGUMENTS.connector,ARGUMENTS.config,ARGUMENTS._request)>
		<cfreturn this>
	</cffunction>

	<cffunction name="name_data" access="public" returntype="string" hint="convert incoming data name to valid db name. Converts c0..cN to valid field names. Return related db_name">
		<cfargument name="data" type="string" required="yes" hint="data name from incoming request">
		<Cfset var local = structNew()>
		<cfif ARGUMENTS.data eq "gr_id">
			<cfreturn "__dummy__id__">
		</cfif> 
		<cfset local.parts = "">
		<cfif left(ARGUMENTS.data,1) eq "c">
			<cfset local.parts = Right(ARGUMENTS.data,len(ARGUMENTS.data)-1)>
		</cfif>
		<cfif isNumeric(local.parts)>
			<cfreturn variables.config.text[local.parts+1]["name"]>
		</cfif>
		<cfreturn ARGUMENTS.data>
	</cffunction>
	<cffunction name="first_loop_form_fields" returntype="string" hint="Get the list from the function 'name_data'">
		<Cfreturn "gr_id">
	</cffunction>
</cfcomponent>
