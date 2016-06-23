<cfcomponent namespace="DataViewConnector" extends="Connector" hint="Connector class for DataView">
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="res" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfif ARGUMENTs.item_type eq "">
			<cfset ARGUMENTs.item_type="DataViewDataItem">
		</cfif> 
		<cfif ARGUMENTs.data_type eq "">
			<cfset ARGUMENTs.data_type="DataProcessor">
		</cfif> 
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="parse_request" access="public" returntype="any" hint="parse GET scoope, all operations with incoming request must be done here">
		<cfset super.parse_request()>
		<cfif isDefined("url.posStart") AND isDefined("url.count")>
			<cfset variables._request.set_limit(url.posStart,url.count)>
		</cfif>	
	</cffunction>
	
	<cffunction name="xml_start" access="public" returntype="string">
		<cfif variables.dload>
			<cfset local.pos = variables._request.get_start()>
			<cfif local.pos>
				<Cfreturn "<data pos='" & local.pos & "'>">
			<cfelse>
				<cfreturn "<data total_count='" & this.sql.get_size(variables._request) & "'>">
			</cfif>	
		<cfelse>
			<cfreturn "<data>">
		</cfif>	
	</cffunction>
</cfcomponent>			