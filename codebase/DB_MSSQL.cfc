<cfcomponent namespace="DB_MSSQL" extends="DBDataWrapper" hint="MSSQL implementation of DataWrapper">
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
				<cfquery datasource="#variables.connectionDSN#" name="local.res">
					#preservesinglequotes(ARGUMENTS.sql)#
				</cfquery>
				<cfquery datasource="#variables.connectionDSN#" name="local.res">
					SELECT @@IDENTITY AS id
				</cfquery>		
				<cfset variables.last_inserted_id = local.res.id>	
			</cflock>	
		<Cfelse>
			<cfquery datasource="#variables.connectionDSN#" name="local.res">
				#preservesinglequotes(ARGUMENTS.sql)#
			</cfquery>
			<cfif NOT isDefined("local.res")>
				<cfset local.res = QueryNew("id")>
			</cfif>
		</cfif>	
		<cfreturn local.res>	
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
		<cfset var local = structNew()>
		<cfset local.sql = "">
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
			<cfset local.sql = "SELECT TOP #evaluate(ARGUMENTS.start+ARGUMENTS.count-1)# #local.id# as dhx_custom_id, #ARGUMENTS.select# FROM #ARGUMENTS.from# #local.where# #local.sort_real#">
			<cfset local.sql = "SELECT #ARGUMENTS.select# FROM (#local.sql#) as tbl WHERE dhx_custom_id NOT IN (SELECT TOP #evaluate(ARGUMENTS.start-1)# #local.id# FROM #ARGUMENTS.from# #local.where# #local.sort_real#) #local.sort#">
		<cfelse>
			<cfset local.sql = "SELECT #local.top# #ARGUMENTS.select# FROM #ARGUMENTS.from# #local.where# #local.sort#">
		</cfif>
		<cfreturn local.sql>
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
	
	<cffunction name="fields_pky" access="public" returntype="string" hint="get pky of the table">
		<cfargument name="table" type="string" required="yes" hint="name of table in question">
		<cfset var local = structNew()>
		<cfsavecontent variable="local.sql">
		<cfoutput>
			SELECT c.COLUMN_NAME as fld 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk, INFORMATION_SCHEMA.KEY_COLUMN_USAGE c 
			WHERE pk.TABLE_NAME = '#ARGUMENTS.table#' 
			AND CONSTRAINT_TYPE = 'PRIMARY KEY'
			AND c.TABLE_NAME = pk.TABLE_NAME
			AND c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
		</cfoutput>	
		</cfsavecontent>
		<cfset local.result = query(local.sql)>
		<cfreturn local.result.fld>
	</cffunction>
</cfcomponent>
