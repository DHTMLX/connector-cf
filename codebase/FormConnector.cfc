<cfcomponent namespace="FormConnector" extends="Connector" hint="Connector class for dhtmlxForm">
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="res" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfif not len(ARGUMENTS.item_type)>
			<cfset ARGUMENTS.item_type="FormDataItem">	
		</cfif>
		<cfif not len(ARGUMENTS.data_type)>
			<cfset ARGUMENTS.data_type="FormDataProcessor">
		</cfif>
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="parse_request" access="public" returntype="any" hint="parse GET scoope, all operations with incoming request must be done here">
		<cfset super.parse_request()>
		<cfif isDefined("URL.id")>
			<cfset variables._request.set_filter(variables.config.id["name"],URL.id,"=")>
		<cfelseif NOT isDefined("form.ids")>
			<cfthrow errorcode="99" message="ID parameter is missed">
		</cfif>	
	</cffunction>
</cfcomponent>