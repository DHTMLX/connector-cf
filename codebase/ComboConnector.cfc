<cfcomponent namespace="ComboConnector" extends="Connector" hint="Connector for the dhtmlxCombo">
	<cfscript>
		//filtering mask from incoming request
		variables.filter = "";
		//position from incoming request
		variables.position = "";
	</cfscript>
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="res" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfif not len(ARGUMENTS.item_type)>
			<cfset ARGUMENTS.item_type="ComboDataItem">	
		</cfif>
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>

	<cffunction name="parse_request" access="public" returntype="any" hint="parse GET scoope, all operations with incoming request must be done here">
		<cfset super.parse_request()>
		<cfif isDefined("URL.pos")>
			<!--- not critical, so just write a log message --->
			<cfif NOT variables.dload>	
				<cfinvoke component="LogMaster" method="do_log">
					<cfinvokeargument name="message" value="Dyn loading request received, but server side was not configured to process dyn. loading. ">
				</cfinvoke>
			<cfelse>
				<cfset variables._request.set_limit(URL.pos,variables.dload)>
			</cfif>	
		</cfif>
		<cfif isDefined("URL.mask")>
			<cfset variables._request.set_filter(variables.config.text[1]["name"],URL.mask & "%","LIKE")>
		</cfif>
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="data" value="#variables._request#">
		</cfinvoke>
	</cffunction>
	
	<cffunction name="xml_start" access="public" returntype="string" hint="renders self as  xml, starting part">
		<cfif variables._request.get_start()>
			<cfreturn "<complete add='true'>">
		<cfelse>
			<cfreturn "<complete>">
		</cfif>		
	</cffunction>
	<cffunction name="xml_end" access="public" returntype="string" hint="renders self as  xml, ending part">
		<cfreturn "</complete>">
	</cffunction>
</cfcomponent>
	