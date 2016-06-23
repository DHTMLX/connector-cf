<cfcomponent namespace="ChartConnector" extends="DataViewConnector" hint="Connector class for DataView">
	<cfscript>
		variables.id_swap = structNew();
	</cfscript>	
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="res" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>
</cfcomponent>			