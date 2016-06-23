<cfcomponent namespace="KeyGridConnector" extends="GridConnector" hint="Connector for the dhtmlxgrid">
	<cfscript>
		//extra info which need to be sent to client side
		variables.extra_output="";
		//hash of OptionsConnector 
		variables.options=structNew();
	</cfscript>
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="res" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfset var local = structNew()>
		<cfif not len(ARGUMENTS.item_type)>
			<cfset ARGUMENTS.item_type="GridDataItem">	
		</cfif>
		<cfif not len(ARGUMENTS.data_type)>
			<cfset ARGUMENTS.data_type="KeyGridDataProcessor">
		</cfif>
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = this>
		<cfset local.ar[2] = "before_check_key">
		<cfset this.event.attach("beforeProcessing",local.ar)>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = this>
		<cfset local.ar[2] = "after_check_key">
		<cfset this.event.attach("afterProcessing",local.ar)>
		<cfreturn this>
	</cffunction>

	<cffunction name="before_check_key" access="public" returntype="void">
		<cfargument name="action" type="any" required="yes">
		<cfif ARGUMENTS.action.get_value(variables.config.id["name"]) eq "">
			<cfset ARGUMENTS.action.error()>
		</cfif>	
	</cffunction>
	<cffunction name="after_check_key" access="public" returntype="void">
		<cfargument name="action" type="any" required="yes">
		<cfif ARGUMENTS.action.get_status() eq "inserted" OR ARGUMENTS.action.get_status() eq "updated">
			<cfset ARGUMENTS.action.success(ARGUMENTS.action.get_value(variables.config.id["name"]))>
			<cfset ARGUMENTS.action.set_status("inserted")>
		</cfif>
	</cffunction>
</cfcomponent>
