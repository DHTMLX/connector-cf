<cfcomponent namespace="TreeMultitableConnector" extends="TreeConnector" hint="Connector for the dhtmlxtree">
	<cfscript>
		variables.level = 0;
		variables.max_level = "";
	</cfscript>
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="res" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfset var local = structNew()>
		<cfset ARGUMENTS.data_type="TreeDataProcessor">
		<cfset super.init(ARGUMENTS.res,ARGUMENTS.type,ARGUMENTS.item_type,ARGUMENTS.data_type)>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = this>
		<cfset local.ar[2] = "id_translate_before">
		<cfset this.event.attach("beforeProcessing",local.ar)>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = this>
		<cfset local.ar[2] = "id_translate_after">
		<cfset this.event.attach("afterProcessing",local.ar)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="render" access="public" returntype="void">
		<cfset var local = structNew()>
		<cfset parse_request()>
		<cfset variables.dload = 1>
		<cfif isDefined("URL.editing") OR isDefined("form.ids")>
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
				<cfset variables._request.set_relation("")>
				<cfset output_as_xml(this.sql.do_select(variables._request))>
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
			<cfset local.data[variables.config.id['name']] = variables.level & '##' & local.data[variables.config.id['name']]>
			<cfset local.data = CreateObject("component",variables.names["item_class"]).init(local.data,variables.config,ARGUMENTS.res.currentRow)>
			<cfset this.event.trigger("beforeRender",local.data)>
			
			
			<cfif isNumeric(variables.max_level) AND(variables.level eq variables.max_level)>
				<cfset local.data.set_kids(0)>
			<cfelse>
				<cfset local.data.set_kids(1)>
			</cfif>
			<cfset local.output = local.output & local.data.to_xml_start()>
			<cfset local.output = local.output & local.data.to_xml_end()>
		</cfloop>
		<cfreturn local.output>
	</cffunction>	
	
	<cffunction name="xml_start" access="public" returntype="string">
		<cfif isDefined("url.id")>
			<cfreturn "<tree id='" & (variables.level - 1) & '##' & url.id & "'>">
		<cfelse>
			<cfreturn "<tree id='0'>">
		</cfif>
	</cffunction>

	<cffunction name="get_level" access="public" returntype="any">
		<cfset var local = structNew()>
		<cfif not isDefined("url.id")>
			<cfif isDefined("form.ids")>
				<cfset local.ids = ListToArray(form.ids)>
				<cfset local.id = parseId(local.ids[1])>
				<cfset variables.level = variables.level -1>
			</cfif>
			<cfset variables._request.set_relation("")>
		<cfelse>
			<cfset local.id = parseId(url.id)>
			<cfset url.id = local.id>
		</cfif>
		<cfreturn variables.level>
	</cffunction>
	
	<cffunction name="parseId" access="public" returntype="string">
		<cfargument name="id" type="string" required="yes">
		<cfargument name="set_level" type="boolean" required="no" default="true">
		<cfset var local = structNew()>
		<cfset local.match = ReFindNoCase("(.+)##",ARGUMENTS.id,1,true)>
		<cfset local.f = mid(ARGUMENTS.id,local.match.pos[2],local.match.len[2])>
		<cfif ARGUMENTS.set_level>
			<cfset variables.level = local.f + 1>
		</cfif>
		
		<cfset local.match = ReFindNoCase("(.+)##(.*)$",ARGUMENTS.id,1,true)>
		<cfif local.match.pos[1]>
			<cfset local.f = mid(ARGUMENTS.id,local.match.pos[3],local.match.len[3])>
			<cfset local.id = local.f>
		<cfelse>	
			<cfset local.id = "">
		</cfif>	
		<cfreturn local.id>
	</cffunction>


	<cffunction name="setMaxLevel" access="public" returntype="void" hint="set maximum level of tree">
		<cfargument name="max_level" type="numeric" required="yes" hint="maximum level">
		<cfset variables.max_level = ARGUMENTS.max_level>
	</cffunction>

	<cffunction name="id_translate_before" access="public" returntype="void" hint="remove level prefix from id, parent id and set new id before processing">
		<cfargument name="action" type="any" required="yes" hint="DataAction object">
		<cfset var local = structNew()>
		<cfset local.id = ARGUMENTS.action.get_id()>
		<cfset local.id = parseId(local.id, false)>
		<cfset ARGUMENTS.action.set_id(local.id)>
		<cfset ARGUMENTS.action.set_value('tr_id', local.id)>
		<cfset ARGUMENTS.action.set_new_id(local.id)>
		<cfset local.pid = ARGUMENTS.action.get_value(variables.config.relation_id['db_name'])>
		<cfset local.pid =parseId(local.pid, false)>
		<cfset ARGUMENTs.action.set_value(variables.config.relation_id['db_name'], local.pid)>
	</cffunction>
	
	<cffunction name="id_translate_after" access="public" returntype="void" hint="add level prefix in id and new id after processing">
		<cfargument name="action" type="any" required="yes" hint="DataAction object">
		<cfset var local = structNew()>
		<cfset local.id = ARGUMENTS.action.get_id()>
		<cfset ARGUMENTS.action.set_id((variables.level) & '##' & local.id)>
		<cfset local.id = ARGUMENTS.action.get_new_id()>
		<cfset ARGUMENTS.action.success((variables.level) & '##' & local.id)>
	</cffunction>
</cfcomponent>
