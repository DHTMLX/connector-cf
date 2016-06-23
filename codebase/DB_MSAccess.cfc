<cfcomponent namespace="DB_MSAccess" extends="DBDataWrapper">
	<cfscript>
	// flag of insert operation
	variables.insert_operation = false;
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="db" type="string" required="yes">
		<cfargument name="config" type="any" required="yes">
		<cfset super.init(ARGUMENTS.config,ARGUMENTS.db)>
		<cfreturn this>	
	</cffunction>
	
	<cffunction name="query" access="public" returntype="query">
		<cfargument name="sql" type="string" required="yes">
		<cfargument name="request" type="any" required="no">
		<cfset var res = "">
		<cfset var local = structNew()>
			
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="SQL">
			<cfinvokeargument name="data" value="#ARGUMENTS.sql#">
		</cfinvoke>
		
		<cfif ReFindNoCase("[\s]*INSERT[\s]+INTO[\s]+",ARGUMENTS.sql) eq 1>
			<cfset variables.insert_operation = true>
		</cfif>
		
		<cfif variables.insert_operation>
			<cflock name="dhtmlX_INSERT" timeout="10" type="readonly">
				<cfquery datasource="#variables.connectionDSN#" name="res">
					#preservesinglequotes(ARGUMENTS.sql)#
				</cfquery>
				<cfset local.id = getId()>
				<cfset local.tbl = ARGUMENTS.request.get_source()>
				<cfquery datasource="#variables.connectionDSN#" name="local.qry">
					SELECT MAX(#local.id#) as dhx_id FROM #local.tbl#
				</cfquery>		
				<cfset res = QueryNew("id")>
				<cfset QueryAddRow(res)>
				<cfset QuerySetCell(res,"id",local.qry.dhx_id)>
			</cflock>	
			<cfset variables.last_inserted_id = res.id>	
		<Cfelse>
			<cfquery datasource="#variables.connectionDSN#" name="res">
				#preservesinglequotes(ARGUMENTS.sql)#
			</cfquery>
			<cfif NOT isDefined("res")>
				<cfset res = QueryNew("id")>
			</cfif>
		</cfif>	
		<cfreturn res>	
	</cffunction>
	
	<cffunction name="insert_query" access="public" returntype="string">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="_request" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.sql = super.insert_query(ARGUMENTS.data,ARGUMENTs._request)>
		<cfset variables.insert_operation=true>
		<cfreturn local.sql>		
	</cffunction>
	<!------------ ----------->
	<cffunction name="select_query" access="public" returntype="string">
		<cfargument name="select" type="string" required="yes">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="where" type="string" required="no" default="">
		<cfargument name="sort" type="string" required="no" default="">
		<cfargument name="start" type="numeric" required="no" default="1">
		<cfargument name="count" type="numeric" required="no" default="0">
		<cfset var sql = "">
		<cfset var local = structNew()>
		<cfset local.id = getId()>

		<cfif ARGUMENTS.count>
			<cfset local.top = "TOP #ARGUMENTS.count#">	
		<Cfelse>
			<cfset local.top = "">		
		</cfif>
		<cfif len(ARGUMENTS.where)>
			<cfset local.where = "WHERE #ARGUMENTS.where#">
		<cfelse>	
			<cfset local.where = "">
		</cfif>
		<cfif len(ARGUMENTS.sort)>
			<cfset local.sort = "ORDER BY #ARGUMENTS.sort#">
		<cfelse>	
			<cfset local.sort = "">
		</cfif>

		<cfif ARGUMENTS.start gt 1>
			<cfif len(ARGUMENTS.sort)>
				<cfset local.sort_real = "#local.sort#, #local.id#">
			<cfelse>
				<cfset local.sort_real = "ORDER BY #local.id#">
			</cfif>
			<cfset sql = "SELECT TOP #evaluate(ARGUMENTS.start+ARGUMENTS.count-1)# #local.id# as dhx_custom_id, #ARGUMENTS.select# FROM #ARGUMENTS.from# #local.where# #local.sort_real#">
			<cfset sql = "SELECT #ARGUMENTS.select# FROM (#sql#) as tbl WHERE dhx_custom_id NOT IN (SELECT TOP #evaluate(ARGUMENTS.start-1)# #local.id# FROM #ARGUMENTS.from# #local.where# #local.sort_real#) #local.sort#">
		<cfelse>
			<cfset sql = "SELECT #local.top# #ARGUMENTS.select# FROM #ARGUMENTS.from# #local.where# #local.sort#">
		</cfif>
		<cfreturn sql>
	</cffunction>	
	<cffunction name="begin_transaction" access="public" returntype="any">
	</cffunction>
	<cffunction name="commit_transaction" access="public" returntype="any">
	</cffunction>
	<cffunction name="rollback_transaction" access="public" returntype="any">
	</cffunction>
	
	<cffunction name="escape_name" access="public" returntype="string" hint="escape field name to prevent sql reserved words conflict">
		<cfargument name="data" type="string" required="yes">
		<cfif ReFindNoCase("[\[\.\(\)]", ARGUMENTS.data)>
			<cfreturn ARGUMENTS.data>
		</cfif>	
		<cfreturn "[" & ARGUMENTS.data & "]">
	</cffunction>
</cfcomponent>
