<cfcomponent namespace="TreeGridGroupConnector" extends="TreeGridConnector" hint="Connector for dhtmlxTreeGrid">
	<cfscript>
		variables.id_postfix = '__{group_param}';
	</cfscript>	
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="res" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfset var local = structNew()>
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = this>
		<cfset local.ar[2] = "check_id">
		<cfset this.event.attach("beforeProcessing",local.ar)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="render" access="public" returntype="void">
		<cfset var local = structNew()>
		<cfif isDefined("URL.id")>
			<cfset url.id = replaceNoCase(UTL.id,variables.id_postfix, "", "all")>
		</cfif>
		<cfset parse_request()>
		<cfif not isDefined("url.id")>
			<cfset variables._request.set_relation("")>
		</cfif>
		<cfif isDefined("url.editing")>
			<cfset variables.editing=true>
		<cfelseif isDefined("FORM.ids")>
			<cfset variables.editing=true>
		<cfelse>
			<cfset variables.editing=false>
		</cfif>
		
		<cfif variables.editing>
			<cfset local.dp = CreateObject("component",variables.names["data_class"]).init(this,variables.config,variables._request)>
			<cfset local.dp.process(variables.config,variables._request)>
		<cfelse>
			<cfset local.wrap = CreateObject("component","SortInterface").init(variables._request)>
			<cfset this.event.trigger("beforeSort",local.wrap)>
			<cfset local.wrap.store()>
			
			<cfset local.wrap = CreateObject("component","FilterInterface").init(variables._request)>
			<cfset this.event.trigger("beforeFilter",local.wrap)>
			<cfset local.wrap.store()>
			
			<cfif isDefined("url.id")>
				<cfset output_as_xml(this.sql.do_select(variables._request))>
			<cfelse>
				<cfset local.relation_id = variables.config.relation_id['name']>
				<cfset output_as_xml(this.sql.get_variants(variables.config.relation_id['name'], variables._request))>
			</cfif>
		</cfif>
		<cfset end_run()>
	</cffunction>	
	
	
	<cffunction name="render_set" access="public" returntype="string">
		<cfargument name="res" type="query" required="yes">
		<cfset var local = structNew()>
		<cfset local.output="">
		<cfloop query="ARGUMENTS.res">
			<cfset local.data=this.sql.get_next(ARGUMENTS.res,ARGUMENTS.res.currentRow)>
			<cfset local.name = variables.config.id['name']>
			<cfif structKeyExists(local.data,local.name)>
				<cfset local.has_kids = false>
			<cfelse>
				<cfset local.data[variables.config.id['name']] = local.data['value'] & variables.id_postfix>
				<cfset local.data[variables.config.text[1]['name']] = local.data['value']>
				<cfset local.has_kids = true>
			</cfif>
			<cfset local.data = CreateObject("component",variables.names["item_class"]).init(local.data,variables.config,ARGUMENTS.res.currentRow)>
			<cfset this.event.trigger("beforeRender",local.data)>
			<cfif not local.has_kids>
				<cfset local.data.set_kids(0)>
			</cfif>
			<cfif local.data.has_kids() neq -1 AND variables.dload>
				<cfset local.data.set_kids(1)>
			</cfif>	
			<cfset local.output = local.output & local.data.to_xml_start()>
			<cfif ((local.data.has_kids() eq -1 OR (local.data.has_kids() AND NOT variables.dload)) AND (local.has_kids))>
				<cfset local.sub_request = CreateObjecT("component","DataRequestConfig").init(variables._request)>
				<cfset local.sub_request.set_relation(replaceNoCase(local.data.get_id(),variables.id_postfix, "", "all"))>
				<cfset local.output = local.output & render_set(this.sql.do_select(local.sub_request))>
			</cfif>
			<cfset local.output = local.output & local.data.to_xml_end()>
		</cfloop>
		<cfreturn local.output>
	</cffunction>	


	<cffunction name="xml_start" access="public" returntype="string">
		<cfif isDefined("url.id")>
			<cfreturn "<rows parent='" & URL.id & variables.id_postfix & "'>">
		<cfelse>
			<cfreturn "<rows parent='0'>">
		</cfif>
	</cffunction>
	
	<cffunction name="check_id" access="public" returntype="any">
		<cfargument name="action" type="any" required="yes">
		<cfset var local = structNew()>
		<cfif isDefined("url.editing")>
			<cfset local.id = ARGUMENTS.action.get_id()>
			<cfset local.pid = ARGUMENTS.action.get_value(variables.config.relation_id['name'])>
			<cfset local.pid = replaceNoCase(local.pid,variables.id_postfix, "", "all")>
			<cfset ARGUMENTS.action.set_value(variables.config.relation_id['name'], local.pid)>
			<cfif NOT FindNOCase(variables.id_postfix,local.id)>
				<cfreturn ARGUMENTS.action>
			<cfelse>
				<cfset ARGUMENTS.action.error()>
				<cfset ARGUMENTS.action.set_response_text("This record can't be updated!")>
				<cfreturn ARGUMENTS.action>
			</cfif>
		<cfelse>
			<cfreturn ARGUMENTS.action>
		</cfif>
	</cffunction>
</cfcomponent>			