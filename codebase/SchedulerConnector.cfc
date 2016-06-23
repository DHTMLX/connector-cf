<cfcomponent namespace="SchedulerConnector" extends="Connector" hint="Connector class for dhtmlxScheduler">
	<!--- extra info which need to be sent to client side --->
	<cfset variables.extra_output="">
	<!--- hash of OptionsConnector  --->
	<cfset variables.options=structNew()>
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="res" type="string" required="yes">
		<cfargument name="type" type="string" required="no" default="">
		<cfargument name="item_type" type="string" required="no" default="">
		<cfargument name="data_type" type="string" required="no" default="">
		<cfif not len(ARGUMENTS.item_type)>
			<cfset ARGUMENTS.item_type="SchedulerDataItem">	
		</cfif>
		<cfif not len(ARGUMENTS.data_type)>
			<cfset ARGUMENTS.data_type="SchedulerDataProcessor">
		</cfif>
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>
	
	
	<cffunction name="set_options" access="public" returntype="void" hint="assign options collection to the column">
		<cfargument name="name" type="string" required="yes" hint="name of the column">
		<cfargument name="options" type="any" required="yes" hint="array or connector object">
		<cfset var local = structNew()>
		<cfif isArray(ARGUMENTS.options)>
			<cfset local.str="">
			<cfloop from="1" to="#ArrayLen(ARGUMENTS.options)#" index="local.k">
				<cfset local.v = ARGUMENTS.options[local.k]>
				<cfset local.str = local.str & "<item value='" & xmlFormat(local.k) & "' label='" & xmlFormat(local.v) & "' />">
			</cfloop>
			<cfset ARGUMENTS.options=local.str>
		</cfif>
		<cfif isStruct(ARGUMENTS.options) AND not isObject(ARGUMENTS.options)>
			<cfset local.str="">
			<cfloop collection="#ARGUMENTS.options#" item="local.k">
				<cfset local.v = ARGUMENTS.options[local.k]>
				<cfset local.str = local.str & "<item value='" & xmlFormat(local.k) & "' label='" & xmlFormat(local.v) & "' />">
			</cfloop>
			<cfset ARGUMENTS.options=local.str>
		</cfif>
		<cfset variables.options[ARGUMENTS.name]=ARGUMENTs.options>
	</cffunction>
	
	
	<cffunction name="fill_collections" access="public" returntype="void" hint="generates xml description for options collections">
		<cfset var local = structNew()>
		<cfloop collection="#variables.options#" item="local.opt">
			<cfset variables.extra_output = variables.extra_output & "<coll_options for='#local.opt#'>">
			<cfif isObject(variables.options[local.opt])>
				<cfset variables.extra_output = variables.extra_output & variables.options[local.opt].render()>
			<cfelse>
				<cfset variables.extra_output = variables.extra_output & variables.options[local.opt]>
			</cfif>	
			<cfset variables.extra_output = variables.extra_output & "</coll_options>">
		</cfloop>
	</cffunction>
		
	<cffunction name="xml_end" access="public" returntype="string" hint="renders self as  xml, ending part">
		<cfset fill_collections()>
		<cfreturn variables.extra_output & "</data>">
	</cffunction>
	
	<cffunction name="parse_request" access="public" returntype="any" hint="parse GET scoope, all operations with incoming request must be done here">
		<cfset super.parse_request()>
		<cfif isDefined("URL.to")>
			<cfset variables._request.set_filter(variables.config.text[1]["name"],URL.to,"<")>
		</cfif>	
		<cfif isDefined("URL.from")>
			<cfset variables._request.set_filter(variables.config.text[2]["name"],URL.from,">")>
		</cfif>	
	</cffunction>
</cfcomponent>