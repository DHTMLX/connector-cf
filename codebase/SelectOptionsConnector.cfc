<cfcomponent namespace="SelectOptionsConnector" extends="Connector" hint="Connector class for dhtmlxForm:options">
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="res" type="any" required="yes">
		<cfargument name="type" type="string" required="no" default="">
		<cfargument name="item_type" type="string" required="no" default="">
		<cfargument name="data_type" type="string" required="no" default="">
		<cfif NOT Len(ARGUMENTS.item_type)>
			<cfset ARGUMENTS.item_type="OptionsDataItem">
		</cfif>	
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>
</cfcomponent>

