<cfcomponent namespace="GridConnector" extends="Connector" hint="Connector for the dhtmlxgrid">
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
		
		<cfif not len(ARGUMENTS.item_type)>
			<cfset ARGUMENTS.item_type="GridDataItem">	
		</cfif>
		<cfif not len(ARGUMENTS.data_type)>
			<cfset ARGUMENTS.data_type="GridDataProcessor">
		</cfif>
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfreturn this>
	</cffunction>
	<cffunction name="parse_request" access="public" returntype="void">
		<cfset super.parse_request()>
		<cfif isDefined("URL.dhx_colls")>
			<cfset fill_collections(URL.dhx_colls)>
		</cfif>
		<cfif isDefined("URL.posStart") AND isDefined("URL.count")>
			<cfset variables._request.set_limit(URL.posStart,URL.count)>
		</cfif>	
	</cffunction>
	<cffunction name="resolve_parameter" access="public" returntype="any">
		<cfargument name="name" type="numeric" required="yes">
		<cfif isNumeric(ARGUMENTS.name)>
			<cfreturn variables.config.text[ARGUMENTS.name]["db_name"]>
		</cfif>
		<cfreturn ARGUMENTS.name>
	</cffunction>	
	<cffunction name="set_options" access="public" returntype="void">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="options" type="any" required="yes">
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
		<cfset variables.options[ARGUMENTS.name]=ARGUMENTS.options>
	</cffunction>	
	
	<cffunction name="fill_collections" access="public" returntype="void" hint="generates xml description for options collections">
		<cfargument name="list" type="string" required="yes" hint="comma separated list of column names, for which options need to be generated">
		<cfset var local = structNew()>
		<cfif not isDefined("this.DistinctOptionsConnectorO")>
			<cfset this.DistinctOptionsConnectorO = CreateObject("component","DistinctOptionsConnector")>
		</cfif>	
		<cfif not isDefined("this.DataConfigO")>
			<cfset this.DataConfigO = createObject("component","DataConfig")>	
		</cfif>
		<cfif not isDefined("this.DataRequestConfigO")>
			<cfset this.DataRequestConfigO = createObject("component","DataRequestConfig")>	
		</cfif>
		<cfset local._saveConfig = createObject("component","DataConfig").init(variables.config)>
		<cfset local.names=ListToArray(ARGUMENTS.list,",")>
		<cfloop from="1" to="#ArrayLen(local.names)#" index="local.i">
			<cfset local.name = resolve_parameter(local.names[local.i]+1)>
			<cfif NOT structKeyExists(variables.options,local.name)>
				<cfset variables.options[local.name] = this.DistinctOptionsConnectorO.init(get_connection(),variables.names["db_class"])>
				<cfset local.c = this.DataConfigO.init(local._saveConfig)>
				<cfset local.r = this.DataRequestConfigO.init(variables._request)>
				<cfset local.c.minimize(local.name)>
				<cfset variables.options[local.name].render_connector(local.c,local.r)>
			</cfif> 
			<cfset local.nameI = local.names[local.i]>
			<cfset variables.extra_output = variables.extra_output & "<coll_options for='#local.nameI#'>">
			<cfif isObject(variables.options[local.name]) OR isStruct(variables.options[local.name]) OR isArray(variables.options[local.name])>
				<cfset variables.extra_output=variables.extra_output & variables.options[local.name].render()>
			<cfelse>
				<cfset variables.extra_output = variables.extra_output & variables.options[local.name]>
			</cfif>	
			<cfset variables.extra_output = variables.extra_output & "</coll_options>">
		</cfloop>
		<cfset variables.config.init(local._saveConfig)>
	</cffunction>	
	
	<cffunction name="xml_start" access="public" returntype="string" hint="renders self as  xml, starting part">
		<cfset var local = structNew()>
		<cfif variables.dload>
			<cfset local.pos = variables._request.get_start()> 
			<cfif local.pos>
				<cfreturn "<rows pos='" & local.pos & "'>">
			<cfelse>
				<cfreturn "<rows total_count='" & this.sql.get_size(variables._request) & "'>">
			</cfif>	
		<cfelse>
			<cfreturn "<rows>">
		</cfif>	
	</cffunction>
	<cffunction name="xml_end" access="public" returntype="string" hint="renders self as  xml, ending part">
		<cfreturn variables.extra_output & "</rows>">
	</cffunction>
	
	
	<cffunction name="set_config" access="public" returntype="void">
		<cfargument name="config" type="any" required="no" default="">
		<cfset var local = structNew()>
		<cfif isBoolean(ARGUMENTS.config)>
			<cfset ARGUMENTS.config = CreateObject("component","GridConfiguration").init(ARGUMENTS.config)>
		</cfif>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = ARGUMENTS.config>
		<cfset local.ar[2] = "attachHeaderToXML">
		<cfset this.event.attach("beforeOutput", local.ar)>
		
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = ARGUMENTS.config>
		<cfset local.ar[2] = "defineOptions">
		<cfset this.event.attach("onInit", local.ar)>
	</cffunction>	
</cfcomponent>
