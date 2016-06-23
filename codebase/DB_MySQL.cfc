<cfcomponent namespace="DB_MySQL" extends="DBDataWrapper">
	<cfset variables.insert_operation = false>
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
					SELECT LAST_INSERT_ID() as id;
				</cfquery>	
				<cfset variables.last_inserted_id = local.res.id>	
			</cflock>	
		<cfelse>
			<!---
			<cfif findNOCase("UPDATE",ARGUMENTS.sql)>
				<cfset local.qry = ArrayNew(1)>
				<cfset local.start = 1>
				<cfloop condition="true">
					<cfset local.match = refindNOCase("\[\[\[([\s\S]*?)\]\]\]",ARGUMENTS.sql,local.start,true)>
					<cfif local.match.pos[1]>
						<cfset local.before = mid(ARGUMENTS.sql,local.start,local.match.pos[1]-local.start)>
						<cfset local.cond = mid(ARGUMENTS.sql,local.match.pos[2],local.match.len[2])>
						<cfset arrayAppend(local.qry,local.before)>
						<cfset arrayAppend(local.qry,"C=" & local.cond)>
						<cfset local.start = local.match.pos[1] + local.match.len[1]>
					<cfelse>
						<cfset local.after = right(ARGUMENTS.sql,len(ARGUMENTS.sql)-local.start+1)>
						<cfset arrayAppend(local.qry,local.after)>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfquery datasource="#variables.connectionDSN#" name="local.res">
					SELECT * 
					FROM tasks
					WHERE 1=0
				</cfquery>
				<cfdump var="#local.res#">
				<cfdump var="#GetMetaData(local.res)#">
				asasa<cfabort>
				<cftry>
				<cfquery datasource="#variables.connectionDSN#" name="local.res">
					<cfloop from="1" to="#ArrayLen(local.qry)#" index="local.i">
						<cfif left(local.qry[local.i],2) eq "C=">
							<cfif local.qry[local.i] contains "{">
								<cfset local.t = "cf_sql_date">
							<cfelse>
								<cfset local.t = "cf_sql_char">		
							</cfif>
							<cfqueryparam value="#right(local.qry[local.i],len(local.qry[local.i])-2)#" cfsqltype="#local.t#">
						<cfelse>
							#local.qry[local.i]#
						</cfif>	
					</cfloop>
				</cfquery>						
				<cfcatch>
					<cfdump var="#cfcatch#">
				</cfcatch>	
				</cftry>
				ok
				<cfabort>
			<cfelse>
			--->
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
		<cfset var sql = "">
		<cfset sql="SELECT " & ARGUMENTS.select & " FROM " & ARGUMENTS.from>
		<cfif len(ARGUMENTS.where)>
			<cfset sql = sql & " WHERE " & ARGUMENTS.where>
		</cfif>
		<cfif len(ARGUMENTS.sort)>
			<cfset sql = sql & " ORDER BY " & ARGUMENTS.sort>
		</cfif>
		<cfif ARGUMENTS.start OR ARGUMENTS.count>
			<cfset sql = sql & " LIMIT " & ARGUMENTS.start & "," & ARGUMENTS.count>
		</cfif>
		<cfreturn sql>
	</cffunction>	
	<cffunction name="begin_transaction" access="public" returntype="any">
		<cfset query("BEGIN")>
	</cffunction>
	<cffunction name="commit_transaction" access="public" returntype="any">
		<cfset query("COMMIT")>
	</cffunction>
	<cffunction name="rollback_transaction" access="public" returntype="any">
		<cfset query("ROLLBACK")>
	</cffunction>
	
	<cffunction name="escape_name" access="public" returntype="string" hint="escape field name to prevent sql reserved words conflict">
		<cfargument name="data" type="string" required="yes">
		<cfif ReFindNoCase("[\[\.\(\)]", ARGUMENTS.data)>
			<cfreturn ARGUMENTS.data>
		</cfif>	
		<cfreturn "`" & ARGUMENTS.data & "`">
	</cffunction>
	
	
	<cffunction name="fields_pky" access="public" returntype="string" hint="get pky of the table">
		<cfargument name="table" type="string" required="yes" hint="name of table in question">
		<cfset var local = structNew()>
		<cfset local.result = query("SHOW COLUMNS FROM `" & ARGUMENTS.table & "`")>
		<cfif local.result.recordCount eq 0>
			<cfthrow errorcode="99" message="MySQL operation failed">
		</cfif>	
		<cfloop query="local.result">
			<cfif local.result.Key eq "PRI">
				<cfreturn local.result.Field>
         	</cfif>
		</cfloop>
		<cfreturn "">
	</cffunction>
	
	<cffunction name="fields_list" access="public" returntype="struct" hint="name of table in question">
		<cfargument name="table" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.result = query("SHOW COLUMNS FROM `" & ARGUMENTS.table & "`")>
		<cfif local.result.recordCount eq 0>
			<cfthrow errorcode="99" message="MySQL operation failed">
		</cfif>	
		<cfset local.fields = arrayNew(1)>
		<cfset local.id = "">
		<cfloop query="local.result">
			<cfset local.fld = local.result[ListFirst(local.result.columnList)][local.result.currentRow]>
			<cfif local.result.Key eq "PRI">
				<cfset local.id = local.result.Field>
            <cfelse>
			 	<cfset ArrayAppend(local.fields,local.result.Field)>
			</cfif>
		</cfloop>
		<cfset local.res = structNew()>
		<cfset local.res.fields = local.fields>
		<cfset local.res.key = local.id>
		<cfreturn local.res>
	</cffunction>
</cfcomponent>
