<cfcomponent namespace="Connector">
	<cfscript>
		variables.lineBreak = "#chr(13)##chr(10)#";
		//DataConfig instance
		variables.config="";				
		//DataRequestConfig instance 	
		variables._request="";			
		//has of names for used classes	
		variables.names = structNew();	
		//assigned encoding (UTF-8 by default) 
		variables.encoding = "utf-8";		
		//flag of edit mode ( response for dataprocessor )
		variables.editing = false;		
		//flag of update mode ( response for data-update )
		variables.updating = false;
		//db connection resource
		variables.db="";		 				
		//flag of dyn. loading mode
		variables.dload = 0;	
		//default value, used to generate auto-IDs
		variables.id_seed=0;
		// actions table name for autoupdating
		variables.live_update = ""; 
		
		variables.limit = "";
		// the current timer
		variables.exec_time = 0;
		
		//AccessMaster instance
		this.access = "";		
		//DataWrapper instance
		this.sql = "";			
		//EventMaster instance
		this.event = "";		
	</cfscript>

	<cffunction name="init" access="public" returntype="any" hint="constructor. Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="db" type="string" required="yes" hint="db connection resource">
		<cfargument name="type" type="string" required="no" default="" hint="string , which hold type of database ( MySQL or Postgre ), optional, instead of short DB name, full name of DataWrapper-based class can be provided">
		<cfargument name="item_type" type="string" required="no" default="" hint="name of class, which will be used for item rendering, optional, DataItem will be used by default">
		<cfargument name="data_type" type="string" required="no" default="" hint="name of class which will be used for dataprocessor calls handling, optional, DataProcessor class will be used by default. ">
		<cfset var local = structNew()>
		
		<cfset variables.exec_time=getTickCount()>
		<cfif NOT Len(ARGUMENTS.type)>
			<cfset ARGUMENTS.type="MySQL">
		</cfif>
		<cfif not Len(ARGUMENTS.item_type)>
			<cfset ARGUMENTS.item_type  = "DataItem">
		</cfif>
		<cfif not Len(ARGUMENTS.data_type)>
			<cfset ARGUMENTS.data_type  = "DataProcessor">
		</cfif>
		<cfif ListFirst(ARGUMENTS.type,"_") neq "DB">
			<cfset variables.names.db_class = "DB_"&ARGUMENTS.type>
		<cfelse>
			<cfset variables.names.db_class = ARGUMENTS.type>	
		</cfif>	
		<cfset variables.names.item_class = ARGUMENTS.item_type>
		<cfset variables.names.data_class = ARGUMENTS.data_type>
		<cfset variables.config = CreateObject("component","DataConfig").init()>
		<cfset variables._request = CreateObject("component","DataRequestConfig").init()>
		<cfset this.event = CreateObject("component","EventMaster").init()>
		<cfset this.access = CreateObject("component","AccessMaster").init()>
		<cfset local.filePath = getDirectoryFromPAth(getCurrentTemplatePath()) & variables.names["db_class"] & ".cfc">
		<cfif NOT fileExists(local.filePath)>
			<cfthrow errorcode="99" message="DB class not found: #variables.names['db_class']#">
		</cfif>
		<cfset this.sql = CreateObject("component",variables.names["db_class"]).init(ARGUMENTS.db,variables.config)>

		<!--- saved for options connectors, if any--->
		<cfset variables.db=ARGUMENTS.db>
		
		<cfinvoke component="EventMaster" method="trigger_static">
			<cfinvokeargument name="name" value="connectorCreate">
			<cfinvokeargument name="2" value="#this#">
		</cfinvoke>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="get_connection" access="public" returntype="string" hint="return db connection resource. nested class may neeed to access live connection object. Return: DB connection resource">
		<cfreturn variables.db>
	</cffunction>
	<cffunction name="get_config" access="public" returntype="any">
		<cfset var local = structNew()>
		<cfset local.cfg = CreateObject("component","DataConfig").init(variables.config)>
		<cfreturn local.cfg>
	</cffunction>
	<cffunction name="get_request" access="public" returntype="any">
		<cfset var local = structNew()>
		<cfset local.cfg = CreateObject("component","DataRequestConfig").init(variables._request)>
		<cfreturn local.cfg>
	</cffunction>
	
	<cffunction name="render_table" access="public" returntype="string" hint="config connector based on table">
		<cfargument name="table" type="string" required="yes" hint="name of table in DB">
		<cfargument name="id" type="string" required="no" default="" hint="name of id field">
		<cfargument name="fields" type="string" required="no" default="" hint="list of fields names">
		<cfargument name="extra" type="string" required="no" default="" hint="list of extra fields, optional, such fields will not be included in data rendering, but will be accessible in all inner events">
		<cfargument name="relation_id" type="string" required="no" default="" hint="name of field used to define relations for hierarchical data organization, optional">
		<cfset configure(ARGUMENTS.table,ARGUMENTS.id,ARGUMENTS.fields,ARGUMENTS.extra,ARGUMENTS.relation_id)>
		<cfif variables.names.db_class neq "DB_FileSystem">
			<cfset this.sql.auto_config_field_types(variables._request.get_source())>
		</cfif>	
		<cfreturn render()>
	</cffunction>
	
	<cffunction name="configure" access="public" returntype="void">
		<cfargument name="table" type="string" required="yes" hint="name of table in DB">
		<cfargument name="id" type="string" required="no" default="" hint="name of id field">
		<cfargument name="fields" type="string" required="no" default="" hint="list of fields names">
		<cfargument name="extra" type="string" required="no" default="" hint="list of extra fields, optional, such fields will not be included in data rendering, but will be accessible in all inner events">
		<cfargument name="relation_id" type="string" required="no" default="" hint="name of field used to define relations for hierarchical data organization, optional">
		<cfset var local = structNew()>
		<cfset local.table = ARGUMENTS.table>
		<cfset local.id = ARGUMENTS.id>
		<cfset local.fields = ARGUMENTS.fields>
		<cfset local.extra = ARGUMENTS.extra>
		<cfset local.relation_id = ARGUMENTS.relation_id>
		<cfif  local.fields eq "">
            <!--- auto-config --->
            <cfset local.info = this.sql.fields_list(ARGUMENTS.table,local.id)>
            <cfset local.fields = ArrayToList(local.info.fields)>
            <cfif local.info.key neq "">
                <cfset local.id = local.info.key>
			</cfif>	
        </cfif>
		<cfset variables.config.init_params(local.id,local.fields,local.extra,local.relation_id)>
		<cfset variables._request.set_source(local.table)>
	</cffunction>
	
	
	<cffunction name="uuid" access="public" returntype="string">
		<cfset variables.id_seed = variables.id_seed+1>
		<cfreturn getTickCount() & "_" & (variables.id_seed-1)>
	</cffunction>

	<cffunction name="render_sql" access="public" returntype="string" hint="config connector based on table">
		<cfargument name="sql" type="string" required="yes" hint="sql query used as base of configuration">
		<cfargument name="id" type="string" required="yes" hint="name of id field">
		<cfargument name="fields" type="string" required="yes" hint="list of fields names">
		<cfargument name="extra" type="string" required="no" default="" hint="list of extra fields, optional, such fields will not be included in data rendering, but will be accessible in all inner events">
		<cfargument name="relation_id" type="string" required="no" default="" hint="name of field used to define relations for hierarchical data organization, optional">
		<cfset variables.config.init_params(ARGUMENTS.id,ARGUMENTS.fields,ARGUMENTS.extra,ARGUMENTS.relation_id)>
		<cfset variables._request.parse_sql(ARGUMENTS.sql)>
		<cfif variables.names.db_class neq "DB_FileSystem">
			<cfset this.sql.auto_config_field_types(variables._request.get_source())>
		</cfif>	
		<cfreturn render()>
	</cffunction>
	
	<cffunction name="render_connector" access="public" returntype="string">
		<cfargument name="config" type="any" required="yes" hint="Config Object">
		<cfargument name="_request" type="any" required="yes" hint="Request object">
		
		<cfset variables.config.copy(ARGUMENTS.config)>
		<cfset variables._request.copy(ARGUMENTS._request)>
		<cfreturn render()>
	</cffunction>

	<cffunction name="render" access="public" returntype="void" hint="render self, process commands, output requested data as XML">
		<cfset var local=structNew()>
		<cfinvoke component="EventMaster" method="trigger_static">
			<cfinvokeargument name="name" value="connectorInit">
			<cfinvokeargument name="2" value="#this#">
		</cfinvoke>
		<cfset parse_request()>
		<cfif isObject(variables.live_update) AND variables.updating>
			<cfset variables.live_update.get_updates()>
		<cfelse>
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
				<cfset output_as_xml(this.sql.do_select(variables._request))>
			</cfif>	
		</cfif>
		<cfset end_run()>
	</cffunction>
	
	<cffunction name="safe_field_name" access="public" returntype="string" hint="prevent SQL injection through column names replace dangerous chars in field names">
		<cfargument name="str" type="string" required="yes" hint="incoming field name">
		<cfreturn ListFirst(ARGUMENTS.str,"#variables.lineBreak##chr(9)#;',")>
	</cffunction>
	
	<cffunction name="set_limit" access="public" returntype="void" hint="limit max count of records connector will ignore any records after outputing max count">
		<cfargument name="limit" type="string" required="yes" hint="max count of records">
		<cfset variables.limit = ARGUMENTS.limit>
	</cffunction>
	
	<cffunction name="parse_request_mode" access="public" returntype="void">
		<!--- detect edit mode --->
        <cfif isDefined("url.editing")>
			<cfset variables.editing=true>
        <cfelseif isDefined("form.ids")>
			<cfset variables.editing=true>
			<cfinvoke component="LogMaster" method="do_log">
				<cfinvokeargument name="message" value="While there is no edit mode mark, POST parameters similar to edit mode detected. Switching to edit mode ( to disable behavior remove POST[ids]">
			</cfinvoke>
		<cfelseif isDefined("url.dhx_version")>
			<cfset variables.updating=true>
        </cfif>
	</cffunction>

	
	<cffunction name="parse_request" access="public" returntype="void" hint="parse incoming request, detects commands and modes">
		<cfset var local= structNew()>
		<cfset local.urlVars = structNew()>
		
		<!--- set default dyn. loading params, can be reset in child classes --->
		<cfif variables.dload>
			<cfset variables._request.set_limit(0,variables.dload)>
		<cfelseif variables.limit neq "">
			<cfset variables._request.set_limit(0,variables.limit)>
		</cfif>	
		<cfset parse_request_mode()>
		<cfif isObject(variables.live_update) AND  (variables.updating OR variables.editing)>
            <cfset variables._request.set_version(URL.dhx_version)>
            <cfset variables._request.set_user(URL.dhx_user)>
        </cfif>
		<cfloop collection="#url#" item="local.k">
			<cfset local.v = URL[local.k]>
			<cfset local.match = ReFindNoCase("([^\[\]]+)\[([\d]+)\]",local.k,1,true)>
			<cfif local.match.pos[1]>
				<cfset local.tmpK = mid(local.k,local.match.pos[3],local.match.len[3])+1>
				<cfset local.tmpV = mid(local.k,local.match.pos[2],local.match.len[2])>
				<cfif not structKeyExists(local.urlVars,local.tmpV)>
					<cfset local.urlVars[local.tmpV] = structNew()>
				</cfif>
				<cfset local.urlVars[local.tmpV][local.tmpK] = local.v>
			</cfif>
		</cfloop>	
		
		<cfif structKeyExists(local.urlVars,"dhx_sort")>
			<cfloop collection="#local.urlVars.dhx_sort#" item="local.k">
				<cfset local.v = safe_field_name(local.urlVars.dhx_sort[local.k])>
				<cfset local.k = safe_field_name(local.k)>
				<cfset variables._request.set_sort(resolve_parameter(local.k),local.v)>
			</cfloop>
		</cfif>		
		
		<cfif structKeyExists(local.urlVars,"dhx_filter")>
			<cfloop collection="#local.urlVars.dhx_filter#" item="local.k">
				<cfset local.v = safe_field_name(local.urlVars.dhx_filter[local.k])>
				<cfset local.k = safe_field_name(local.k)>
				<cfset variables._request.set_filter(resolve_parameter(local.k),local.v)>
			</cfloop>
		</cfif>	
		
	</cffunction>

	<cffunction name="resolve_parameter" access="public" returntype="string" hint="convert incoming request name to the actual DB name. Return: name of related DB field">
		<cfargument name="name" type="string" required="yes" hint="incoming parameter name">
		<cfreturn ARGUMENTS.name>
	</cffunction>

	<cffunction name="render_set" access="public" returntype="string" hint="render from DB resultset, process commands, output requested data as XML">
		<cfargument name="res" type="query" required="yes" hint="DB resultset">
		<cfset var local = structNew()>
		<cfset local.output="">
		<cfloop query="ARGUMENTS.res">
			<cfset local.data=this.sql.get_next(ARGUMENTS.res,ARGUMENTS.res.currentRow)>
			<cfset local.data = CreateObject("component",variables.names["item_class"]).init(local.data,variables.config,ARGUMENTS.res.currentRow)>
			<cfif local.data.get_id() eq "">
				<cfset local.data.set_id(uuid())>
			</cfif>	
			<cfset this.event.trigger("beforeRender",local.data)>
			<cfset local.output = local.output & local.data.to_xml()>
		</cfloop>
		<cfreturn local.output>
	</cffunction>
	
	<cffunction name="output_as_xml" access="public" returntype="string" hint="output fetched data as XML">
		<cfargument name="res" type="query" required="yes" hint="DB resultset ">
		<cfset var local = structNew()>
		<cfset local.start="<?xml version='1.0' encoding='" & variables.encoding & "' ?>" & xml_start()>
		<cfset local.end=render_set(ARGUMENTS.res) & xml_end()>
		<cfset local.out = CreateObjecT("component","OutputWriter").init(local.start, local.end, variables.encoding)>
		<cfset this.event.trigger("beforeOutput", this,local.out)>
		<cfset local.out.output()>
	</cffunction>
	
	<cffunction name="end_run" access="public" returntype="void" hint="end processing, stop execution timer, kill the process">
		<cfset var local = structNew()>
		<cfset local.time=getTickCount() - variables.exec_time>
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="Done in #local.time# ms.">
		</cfinvoke>
		<cfflush>
		<cfabort>
	</cffunction>	

	<cffunction name="set_encoding" access="public" returntype="void" hint="set xml encoding, methods sets only attribute in XML, no real encoding conversion occurs	">
		<cfargument name="encoding" type="string" required="yes" hint="value which will be used as XML encoding">
		<cfset variables.encoding = ARGUMENTS.encoding>
	</cffunction>
	
	<cffunction name="dynamic_loading" access="public" returntype="void" hint="enable or disable dynamic loading mode">
		<cfargument name="count" type="numeric" required="yes" hint="count of rows loaded from server, actual only for grid-connector, can be skiped in other cases. If value is a false or 0 - dyn. loading will be disabled">
		<cfset variables.dload=ARGUMENTS.count>
	</cffunction>

	<cffunction name="enable_log" access="public" returntype="void" hint="enable logging">
		<cfargument name="vars" type="struct" required="yes" hint="variables struct. Error is present here">
		<cfargument name="path" type="string" required="no" default="" hint="path to the log file. If set as empty strig - logging will be disabled">
		<cfargument name="output" type="boolean" required="no" default="false" hint="enable output of log data to the client side">
		
		<cfinvoke component="LogMaster" method="enable_log">
			<cfinvokeargument name="vars" value="#ARGUMENTS.vars#">
			<cfinvokeargument name="path" value="#ARGUMENTS.path#">
			<cfinvokeargument name="output" value="#ARGUMENTS.output#">
		</cfinvoke>
	</cffunction>
	
	<cffunction name="is_select_mode" access="public" returntype="boolean" hint="provides infor about current processing mode. Return: true if processing dataprocessor command, false otherwise">
		<cfset parse_request_mode()>
		<cfreturn NOT variables.editing>
	</cffunction>
	<cffunction name="is_first_call" access="public" returntype="boolean" hint="provides infor about current processing mode. Return: true if processing dataprocessor command, false otherwise">
		<cfset parse_request_mode()>
		<cfreturn not (variables.editing OR variables.updating OR variables._request.get_start() OR isDefined("url.dhx_no_header"))>
	</cffunction>
	
	<cffunction name="xml_start" access="public" returntype="string">
		<cfreturn "<data>">
	</cffunction>
	<cffunction name="xml_end" access="public" returntype="string">
		<cfreturn "</data>">
	</cffunction>
	
	<cffunction name="do_insert" access="public" returntype="string">
		<cfargument name="data" type="struct" required="yes">
		<cfset var local = structNew()>
		<cfset local.action = CreateObject("component","DataAction").init("inserted", "", ARGUMENTS.data)>
		<cfset local._request = CreateObject("component","DataRequestConfig").init()>
		<cfset local._request.set_source(variables._request.get_source())>
		<cfset variables.config.limit_fields(ARGUMENTS.data)>
		<cfset this.sql.do_insert(local.action,local._request)>
		<cfset variables.config.restore_fields(ARGUMENTS.data)>
		<cfreturn local.action.get_new_id()>
	</cffunction>
	
	<cffunction name="do_delete" access="public" returntype="string">
		<cfargument name="id" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.action = CreateObject("component","DataAction").init("deleted", ARGUMENTS.id, structNew())>
		<cfset local._request = CreateObject("component","DataRequestConfig").init()>
		<cfset local._request.set_source(variables._request.get_source())>
		<cfset this.sql.do_delete(local.action,local._request)>
		<cfreturn local.action.get_status()>
	</cffunction>
	
	<cffunction name="do_update" access="public" returntype="string">
		<cfargument name="data" type="struct" required="yes">
		<cfset var local = structNew()>
		<cfset local.action = CreateObject("component","DataAction").init("updated", ARGUMENTS.data[variables.config.id["name"]], ARGUMENTS.data)>
		<cfset local._request = CreateObject("component","DataRequestConfig").init()>
		<cfset local._request.set_source(variables._request.get_source())>
		
		<cfset variables.config.limit_fields(ARGUMENTS.data)>
		<cfset this.sql.do_update(local.action,local._request)>
		<cfset variables.config.restore_fields()>
		<cfreturn local.action.get_status()>
	</cffunction>
	
	<cffunction name="enable_live_update" access="public" returntype="void" hint="sets actions_table for Optimistic concurrency control mode and start it">
		<cfargument name="table" type="string" required="yes" hint="name of database table which will used for saving actions">
		<cfargument name="_url" type="string" required="no" default="" hint="url used for update notifications">

		<cfset var local = structNew()>
		<cfset variables.live_update = CreateObject("component","DataUpdate").init(this.sql, variables.config, variables._request, ARGUMENTS.table,ARGUMENTS._url)>
        <cfset variables.live_update.set_event(this.event,variables.names["item_class"])>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = variables.live_update>

		<cfset local.ar[2] = "version_output">
		<cfset this.event.attach("beforeOutput",local.ar)>
		<cfset local.ar[2] = "get_updates">
		<cfset this.event.attach("beforeFiltering",local.ar)>
		<cfset local.ar[2] = "check_collision">
		<cfset this.event.attach("beforeProcessing",local.ar)>
		<cfset local.ar[2] = "log_operations">
		<cfset this.event.attach("afterProcessing",local.ar)>
	</cffunction>
</cfcomponent>
