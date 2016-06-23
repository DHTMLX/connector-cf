<cfcomponent namespace="DataUpdate" hint="contain all info related to action and controls customizaton">
	<cfscript>
		//table , where actions are stored
		variables.table="";
		//url for notification service, optional
		variables._url="";
		//DB wrapper object
		variables.sql="";
		//DBConfig object
		variables.config="";
		//DBRequestConfig object
		variables._request="";

		variables.event="";
		variables.item_class="";
		variables.demu="";
	</cfscript>
	 
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="sql" type="any" required="yes" hint="DB object">
		<cfargument name="config" type="any" required="yes" hint="DataConfig object">
		<cfargument name="_request" type="any" required="yes" hint="DataRequestConfig object">
		<cfargument name="table" type="any" required="yes" hint="">
		<cfargument name="_url" type="any" required="yes" hint="">
		<cfset variables.sql=ARGUMENTS.sql>
		<cfset variables.config=ARGUMENTs.config>
		<cfset variables._request=ARGUMENTS._request>
		<cfset variables.table=ARGUMENTS.table>
		<cfset variables._url=ARGUMENTS._url>
		<cfset variables.demu="">
		
		<cfset variables.sql.auto_config_field_types(variables.table)>
		<cfreturn this>
	</cffunction>
	
	
	<cffunction name="set_demultiplexor" access="public" returntype="void">
		<cfargument name="path" type="any" required="yes">
		<cfset variables.demu = ARGUMENTS.path>
	</cffunction>
	
	<cffunction name="set_event" access="public" returntype="void">
		<cfargument name="master" type="any" required="yes">
		<cfargument name="name" type="any" required="yes">
		<cfset variables.event = ARGUMENTS.master>
		<cfset variables.item_class = ARGUMENTS.name>
	</cffunction>
	
	<cffunction name="select_update" access="public" returntype="string">
		<cfargument name="actions_table" type="string" required="yes">
		<cfargument name="join_table" type="string" required="yes">
		<cfargument name="id_field_name" type="string" required="yes">
		<cfargument name="version" type="string" required="yes">
		<cfargument name="user" type="string" required="yes">
		<cfset var local = structNew()>
		<cfif ARGUMENTS.version eq "undefined">
			<cfset ARGUMENTS.version = -1>
		</cfif>
		<cfset local.sql = "SELECT * FROM  #ARGUMENTS.actions_table#">
		<cfset local.sql = local.sql & " LEFT OUTER JOIN #ARGUMENTS.join_table# ON ">
		<cfset local.sql = local.sql & "#ARGUMENTS.actions_table#.DATAID = #ARGUMENTS.join_table#.#ARGUMENTS.id_field_name# ">
		<cfset local.sql = local.sql & "WHERE #ARGUMENTS.actions_table#.#variables.sql.escape_name("ID")# > #variables.sql.escape_smart(ARGUMENTS.version,"id")# AND #ARGUMENTS.actions_table#.#variables.sql.escape_name("USER")# <> #variables.sql.escape_smart(ARGUMENTS.user,"user")#">
		<cfreturn local.sql>
	</cffunction>
	
	<cffunction name="get_update_max_version" access="public" returntype="string">
		<cfset var local = structNew()>
		<cfset local.sql = "SELECT MAX(id) as VERSION FROM #variables.table#">
		<cfset local.res = variables.sql.query(local.sql)>
		<cfif local.res.recordCount eq 0 OR local.res['VERSION'][1] eq "">
			<cfreturn "1">
		<cfelse>
			<cfreturn local.res['VERSION'][1]>
		</cfif>	
	</cffunction>
	
	
	<cffunction name="log_update_action" access="public" returntype="void">
		<cfargument name="actions_table" type="string" required="yes">
		<cfargument name="dataId" type="string" required="yes">
		<cfargument name="status" type="string" required="yes">
		<cfargument name="user" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.sql = "INSERT INTO #ARGUMENTS.actions_table# (DATAID, TYPE, USER) VALUES (#variables.sql.escape_smart(ARGUMENTS.dataId,'DATAID')#, #variables.sql.escape_smart(ARGUMENTS.status,'type')#, #variables.sql.escape_smart(ARGUMENTS.user,'user')#)">
		<cfset variables.sql.query(local.sql)>
		<cfif variables.demu neq "">
            <!---- ---->
		</cfif>	
	</cffunction>
	
	<cffunction name="log_operations" access="public" returntype="void" hint="records operations in actions_table">
		<cfargument name="action" type="any" required="yes" hint="DataAction object">
		<cfset var local = structNew()>
		
		<cfset local.type = variables.sql.escape(ARGUMENTS.action.get_status())>
		<cfset local.dataId = variables.sql.escape(ARGUMENTS.action.get_new_id())>
		<cfset local.user = variables.sql.escape(variables._request.get_user())>
		<cfif local.type neq "error" AND local.type neq "invalid" AND local.type  neq "collision">
			<cfset log_update_action(variables.table, local.dataId, local.type, local.user)>
		</cfif>
	</cffunction>
	

	<cffunction name="get_version" access="public" returntype="string" hint="return action version in XMl format">
		<cfset var local = structNew()>
		<cfset local.version = get_update_max_version()>
		<cfreturn "<userdata name='version'>" & local.version & "</userdata>">
	</cffunction>


	<cffunction name="version_output" access="public" returntype="void" hint=" adds action version in output XML as userdata">
		<cfoutput>#get_version()#</cfoutput>
	</cffunction>
	
	<cffunction name="get_updates" access="public" returntype="void" hint=" create update actions in XML-format and sends it to output">
		<cfset var local = structNew()>
		
		<cfset local.sub_request = CreateObjecT("component","DataRequestConfig").init(variables._request)>
		<cfset local.version = variables._request.get_version()>
		<cfset local.user =	variables._request.get_user()>
		<cfset local.sub_request.parse_sql(select_update(variables.table, variables._request.get_source(), variables.config.id['db_name'], local.version, local.user))>
		<cfset local.sub_request.set_relation("")>
		<cfset local.output = render_set(variables.sql.do_select(local.sub_request), variables.item_class)>
        
		<cfcontent type="text/xml" reset="yes"><cfoutput>#updates_start()##get_version()##local.output##updates_end()#</cfoutput>
	</cffunction>
	
	<cffunction name="render_set" access="public" returntype="string">
		<cfargument name="res" type="query" required="yes">
		<cfargument name="name" type="any" required="yes">
		<cfset var local = structNew()>
		
		<cfset local.output="">
		<cfloop query="ARGUMENTS.res">
			<cfset local.data = variables.sql.get_next(ARGUMENTS.res,ARGUMENTS.res.currentRow)>
			<cfset local.data = CreateObjecT("component","DataItemUpdate").init(local.data,variables.config,ARGUMENTS.res.currentRow, ARGUMENTS.name)>
			<cfset variables.event.trigger("beforeRender",local.data)>
			<cfset local.output = local.output & local.data.to_xml()>
		</cfloop>
		<cfreturn local.output>
	</cffunction>
	
	<cffunction name="updates_start" access="public" returntype="string" hint="returns update start string">
		<cfset var local = structNew()>
		<cfset local.start = '<updates>'>
		<cfreturn local.start>
	</cffunction>
	
	<cffunction name="updates_end" access="public" returntype="string" hint="returns update end string">
		<cfset var local = structNew()>
		<cfset local.start = '</updates>'>
		<cfreturn local.start>
	</cffunction>

	<cffunction name="check_collision" access="public" returntype="void" hint="checks if action version given by client is deprecated">
		<cfargument name="action" type="any" required="yes" hint="DataAction object">
		<cfset var local = structNew()>
		<cfset local.version = variables.sql.escape(variables._request.get_version())>
		<cfset local.last_version = get_update_max_version()>
		<cfif  local.last_version gt local.version AND ARGUMENTS.action.get_status() eq 'update'>
			<cfset ARGUMENTS.action.error()>
			<cfset ARGUMENTS.action.set_status('collision')>
		</cfif>
	</cffunction>
</cfcomponent>
	