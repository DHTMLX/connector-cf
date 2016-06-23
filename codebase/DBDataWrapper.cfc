<!--- ----------------------------------------------------------------------------
	Base abstraction class, used for data operations
	Class provides base set of methods to access and change data in DB, class used as a base for DB-specific wrappers
---------------------------------------------------------------------------- ---> 
<cfcomponent namespace="DBDataWrapper">
	<cfscript>
		variables.connectionDSN="";
		//DataConfig instance
		variables.config="";		
		//type of transaction	
		variables.transaction = "";
		//sequence name
		variables.sequence = "";
		//predefined sql actions
		variables.sqls = StructNew();
		// Last inserted ID
		variables.last_inserted_id = 0;
		// Field types. 
		variables.field_types = structNew();
	</cfscript>
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="config" type="any" required="yes">
		<cfargument name="connectionDSN" type="any" required="yes">
		<cfset variables.config = ARGUMENTS.config>
		<cfset variables.connectionDSN = ARGUMENTS.connectionDSN>
		<cfreturn this>
	</cffunction>
	<cffunction name="dump" access="public" returntype="void">
		<cfdump var="#variables#">
	</cffunction>	
	<cffunction name="getId" access="public" returntype="string" hint="get the ID of the current table">
		<cfreturn variables.config.id["db_name"]>
	</cffunction>
	<cffunction name="attach" access="public" returntype="void" hint="assign named sql query">
		<cfargument name="name" type="string" required="yes" hint="name of sql query">
		<cfargument name="data" type="string" required="yes" hint="sql query text">
		<cfset variables.sqls[ARGUMENTS.name]=ARGUMENTS.data>
	</cffunction>
	
	<cffunction name="get_sql" access="public" returntype="string">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="data" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.matches = ArrayNew(1)>
		
		<cfif NOT structKeyExists(variables.sqls,ARGUMENTS.name)>
			<cfreturn "">
		</cfif>	
		<cfset local.str = variables.sqls[ARGUMENTS.name]>
		
		
		<cfset local.start = 1>
		<cfloop condition="true">
			<cfset local.match = refindNoCase("\{([^}]+)\}",local.str,local.start,true)>
			<cfif local.match.pos[1]>
				<cfset local.ind = ArrayLen(local.matches)+1>
				<cfset local.matches[local.ind] = structNew()>
				<cfset local.matches[local.ind].from = mid(local.str,local.match.pos[1],local.match.len[1])>
				<cfset local.matches[local.ind].to = mid(local.str,local.match.pos[2],local.match.len[2])>
				<cfset local.start = local.match.pos[1]+local.match.len[1]>
			<cfelse>
				<cfbreak>	
			</cfif>
		</Cfloop>
		<cfloop from="1" to="#ArrayLen(local.matches)#" index="local.i">
			<cfset local.str = replaceNOCase(local.str,local.matches[local.i].from,escape(ARGUMENTS.data.get_value(local.matches[local.i].to)),"all")>	
		</cfloop>
		<cfreturn local.str>
	</cffunction>	
	
	<cffunction name="do_insert" access="public" returntype="void">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="source" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.sql = insert_query(ARGUMENTS.data, ARGUMENTS.source)>
		<cfset variables.last_inserted_id = query(local.sql,ARGUMENTS.source).id>
		<cfset ARGUMENTS.data.success(get_new_id())>
	</cffunction>
	<cffunction name="do_delete" access="public" returntype="void">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="source" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.sql = delete_query(ARGUMENTS.data, ARGUMENTS.source)>
		<cfset query(local.sql)>
		<cfset ARGUMENTS.data.success()>
	</cffunction>
	<cffunction name="do_update" access="public" returntype="void">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="source" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.sql = update_query(ARGUMENTS.data, ARGUMENTS.source)>
		<cfset query(local.sql)>
		<cfset ARGUMENTS.data.success()>
	</cffunction>
	<cffunction name="do_select" access="public" returntype="any">
		<cfargument name="source" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.select=ARGUMENTS.source.get_fieldset()>
		<cfif NOT Len(local.select)>
			<cfset local.select=variables.config.db_names_list(this)>
		</cfif>
		<cfset local.where=build_where(ARGUMENTS.source.get_filters(),ARGUMENTS.source.get_relation())>
		<cfset local.sort=build_order(ARGUMENTS.source.get_sort_by())>
		<cfreturn query(select_query(local.select,ARGUMENTS.source.get_source(),local.where,local.sort,ARGUMENTS.source.get_start(),ARGUMENTS.source.get_count()))>
	</cffunction>
	<cffunction name="get_size" access="public" returntype="any">
		<cfargument name="source" type="any" required="yes">
		<cfset var local = structNew()>
		
		<cfset local.count = CreateObject("component","DataRequestConfig").init(ARGUMENTS.source)>
		<cfset local.select= ARGUMENTS.source.get_fieldset()>
		<cfif NOT len(local.select)>
			<cfset local.select=variables.config.db_names_list(this)>
		</cfif>	
			
		<cfset local.count.set_fieldset("COUNT(*) as DHX_COUNT ")>
		<cfset local.count.set_sort("")>
		<cfset local.count.set_limit(0,0)>
		
		<cfset local.res=do_select(local.count)>
		<cfset local.data=get_next(local.res,1)>
		<cfreturn local.data["DHX_COUNT"]>
	</cffunction>
	<cffunction name="get_variants" access="public" returntype="any">
		<cfargument name="name" type="any" required="yes">
		<cfargument name="source" type="any" required="yes">
		<cfset var local = structNew()>
		
		<cfset local.count = CreateObject("component","DataRequestConfig").init(ARGUMENTS.source)>
		<cfset local.count.set_fieldset("DISTINCT " & this.escape_name(ARGUMENTS.name) & " as " & this.escape_name("value"))>
		<cfset local.count.set_sort("")>
		<cfset local.count.set_limit(0,0)>
		<cfreturn do_select(local.count)>
	</cffunction>
	<cffunction name="sequence" access="public" returntype="any">
		<cfargument name="sec" type="any" required="yes">
		<cfset variables.sequence = ARGUMENTS.sec>
	</cffunction>
	<cffunction name="build_where" access="public" returntype="any">
		<cfargument name="rules" type="any" required="yes">
		<cfargument name="relation" type="any" required="no" default="">
		<cfset var local = structNew()>
		<cfset local.sql=ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.rules)#" index="local.i">
			<cfif NOt isStruct(ARGUMENTS.rules[local.i])>
				<cfset ArrayAppend(local.sql,ARGUMENTS.rules[local.i])>
			<cfelse>
				<cfif ARGUMENTS.rules[local.i]["value"] neq "">
					<cfif NOt len(ARGUMENTS.rules[local.i]["operation"])>
						<cfset ArrayAppend(local.sql,escape_name(ARGUMENTS.rules[local.i]["name"]) & " LIKE '%" & escape(ARGUMENTS.rules[local.i]["value"]) & "%'")>
					<cfelse>
						<cfset ArrayAppend(local.sql,escape_name(ARGUMENTS.rules[local.i]["name"]) & " " & ARGUMENTS.rules[local.i]["operation"] &" "& escape_smart(ARGUMENTS.rules[local.i]["value"],ARGUMENTS.rules[local.i]["name"]))>
					</cfif>	
				</cfif>
			</cfif>	
		</cfloop>	
		<cfif Len(ARGUMENTS.relation)>
			<Cfset ArrayAppend(local.sql,escape_name(variables.config.relation_id["db_name"]) &  " = " & escape_smart(ARGUMENTS.relation,variables.config.relation_id["db_name"]))>
		</cfif>	
		<cfreturn ArrayToList(local.sql," AND ")>
	</cffunction>
	<cffunction name="build_order" access="public" returntype="any">
		<cfargument name="by" type="any" required="yes">
		<cfset var local = structNew()>
		<cfif NOt ArrayLen(ARGUMENTS.by)>
			<cfreturn  "">
		</cfif>
		<cfset local.out = ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.by)#" index="local.i">
			<cfif Len(ARGUMENTS.by[local.i]["name"])>
				<cfset ArrayAppend(local.out,escape_name(ARGUMENTS.by[local.i]["name"]) & " " & ARGUMENTS.by[local.i]["direction"])>
			</cfif>	
		</cfloop>
		<cfreturn ArrayToList(local.out,",")>
	</cffunction>
	
	<cffunction name="select_query" access="public" returntype="string">
		<cfargument name="select" type="string" required="yes">
		<cfargument name="from" type="string" required="yes">
		<cfargument name="where" type="string" required="no" default="">
		<cfargument name="sort" type="string" required="no" default="">
		<cfargument name="start" type="numeric" required="no" default="1">
		<cfargument name="count" type="numeric" required="no" default="0">
		
		<cfset var local = structNew()>
		<cfset local.sql="SELECT " & ARGUMENTS.select & " FROM " & ARGUMENTS.from>
		<cfif len(ARGUMENTS.where)>
			<cfset local.sql = local.sql & " WHERE " & ARGUMENTS.where>
		</cfif>
		<cfif len(ARGUMENTS.sort)>
			<cfset local.sql = local.sql & " ORDER BY " & ARGUMENTS.sort>
		</cfif>
		<cfif ARGUMENTS.start OR ARGUMENTS.count>
			<!--- different actions --->
			<!--- MY SQL sample: 
			<cfif ARGUMENTS.start OR ARGUMENTS.count>
				<cfset sql = sql & " LIMIT " & ARGUMENTS.start & "," & ARGUMENTS.count>
			</cfif>
			--->
		</cfif>
		<cfreturn local.sql>
	</cffunction>
	
	<cffunction name="update_query" access="public" returntype="string" hint="generates update sql. Return: sql string, which updates record with provided data">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="_request" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.sql="UPDATE " & ARGUMENTS._request.get_source() & " SET ">
		<cfset local.temp=ArrayNew(1)>
		<cfloop  from="1" to="#ArrayLen(variables.config.text)#" index="local.i">
			<cfset local.step=variables.config.text[local.i]>
			<cfset local.temp[local.i] = escape_name(local.step["db_name"]) & "=" & escape_smart(ARGUMENTS.data.get_value(local.step["name"]),local.step["db_name"])>
		</cfloop>
		<cfset local.relation = variables.config.relation_id["db_name"]>
		<cfif local.relation neq "">
			<cfset ArrayAppend(local.temp,escape_name(local.relation) & "=" & escape_smart(ARGUMENTS.data.get_value(local.relation),local.relation))>
		</cfif>
		<cfset local.sql = local.sql & ArrayToList(local.temp,",") & " WHERE " & escape_name(variables.config.id["db_name"]) & "=" & escape_smart(ARGUMENTS.data.get_id(),variables.config.id["db_name"])>
		
		<!--- if we have limited set - set constraints --->
		<cfset local.where=build_where(ARGUMENTS._request.get_filters(),ARGUMENTS._request.get_relation())>
		<cfif Len(local.where)>
			<cfset local.sql = local.sql & " AND (" & local.where & ")">
		</cfif> 
		<cfreturn local.sql>
	</cffunction>
	
	<cffunction name="delete_query" access="public" returntype="string" hint="generates delete sql. Return: sql string, which delete record">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="_request" type="any" required="yes">
		<cfset var local = structNew()>
			
		<cfset local.sql="DELETE FROM " & ARGUMENTs._request.get_source()>
		<cfset local.sql = local.sql & " WHERE " & escape_name(variables.config.id["db_name"]) & "=" & escape_smart(ARGUMENTS.data.get_id(),variables.config.id["db_name"])>
		
		<!--- if we have limited set - set constraints--->
		<cfset local.where=build_where(ARGUMENTS._request.get_filters(),ARGUMENTs._request.get_relation())>
		
		<cfif len(local.where) >
			<cfset local.sql = local.sql & " AND (" & local.where & ")">
		</cfif>
		<cfreturn local.sql>
	</cffunction>

	<cffunction name="insert_query" access="public" returntype="string" hint="generates insert sql. Return: sql string, which inserts new record with provided data">
		<cfargument name="data" type="any" required="yes">
		<cfargument name="_request" type="any" required="yes">
		<cfset var local = structNew()>
	
		<cfset local.temp_n=ArrayNew(1)>
		<cfset local.temp_v=ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(variables.config.text)#" index="local.i">
			<cfset local.v = variables.config.text[local.i]>
			<cfset local.temp_n[local.i]=escape_name(local.v["db_name"])>
			<cfset local.temp_v[local.i]=escape_smart(ARGUMENTS.data.get_value(local.v["name"]),local.v["db_name"])>
		</cfloop>
		
		
		<cfset local.relation = variables.config.relation_id["db_name"]>
		<cfif len(local.relation)>
			<cfset ArrayAppend(local.temp_n,escape_name(local.relation))>
			<cfset ArrayAppend(local.temp_v,escape_smart(ARGUMENTS.data.get_value(local.relation),local.relation))>
		</cfif>
		<cfif len(variables.sequence)>
			<cfset ArrayAppend(local.temp_n,escape_name(variables.config.id["db_name"]))>
			<cfset ArrayAppend(local.temp_v,escape_smart(variables.sequence,variables.config.id["db_name"]))>
		</cfif>
		<cfset local.sql="INSERT INTO " & ARGUMENTS._request.get_source() & "(" & ArrayToList(local.temp_n,",") & ") VALUES (" & ArrayToList(local.temp_v,",") & ")">
		<cfreturn local.sql>
	</cffunction>
	
	<cffunction name="set_transaction_mode" access="public" returntype="any">
		<cfargument name="mode" type="any" required="yes">
		<cfif Not ListFindNoCase("none,global,record",ARGUMENTs.mode)>
			<cfthrow errorcode="99" message="Unknown transaction mode">
		</cfif>	
		<cfset variables.transaction=ARGUMENTS.mode>
	</cffunction>	
	
	<cffunction name="is_global_transaction" access="public" returntype="any">
		<cfif variables.transaction eq "global">
			<cfreturn true>
		<cfelse>
			<cfreturn false>	
		</cfif>
	</cffunction>
	
	<cffunction name="is_record_transaction" access="public" returntype="any">
		<cfif variables.transaction eq "record">
			<cfreturn true>
		<cfelse>
			<cfreturn false>	
		</cfif>
	</cffunction>

	<cffunction name="begin_transaction" access="public" returntype="any">
		<cfthrow errorcode="99" message="Data wrapper not supports transactions.">
	</cffunction>
	<cffunction name="commit_transaction" access="public" returntype="any">
		<cfthrow errorcode="99" message="Data wrapper not supports transactions.">
	</cffunction>
	<cffunction name="rollback_transaction" access="public" returntype="any">
		<cfthrow errorcode="99" message="Data wrapper not supports transactions.">
	</cffunction>
	
	<cffunction name="query" access="public" returntype="query">
		<cfargument name="sql" type="string" required="yes">
		<cfargument name="_request" type="any" required="no">
		<cfset var local = structNew()>
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="SQL">
			<cfinvokeargument name="data" value="#ARGUMENTS.sql#">
		</cfinvoke>
		<cfquery datasource="#variables.connectionDSN#" name="local.res">
			#preservesinglequotes(ARGUMENTS.sql)#
		</cfquery>
		<cfif NOT isDefined("local.res")>
			<cfset local.res = QueryNew("id")>
		</cfif>
		<cfreturn local.res>	
	</cffunction>
	<cffunction name="get_next" access="public" returntype="struct">
		<cfargument name="data" type="query" required="yes">
		<cfargument name="ind" type="numeric" required="no" default="1">
		<cfset var local = structNew()>
		<cfloop list="#ARGUMENTS.data.columnList#" index="local.fld">
			<cfset local.res[local.fld] = ARGUMENTS.data[local.fld][ARGUMENTS.ind]>
		</cfloop>
		<cfreturn local.res>
	</cffunction>
	<cffunction name="escape" access="public" returntype="string">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="name" type="string" required="no" default="">
		<cfset var local = structNew()>
		<cfreturn replaceNOCase(ARGUMENTS.value,"'","''","all")>
	</cffunction>
	<cffunction name="escape_smart" access="public" returntype="string" hint="Escapes the value according to the name type">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="name" type="string" required="no" default="">
		<cfset var local = structNew()>
		
		<cfset local.res = "'" & replaceNOCase(ARGUMENTS.value,"'","''","all") & "'">
		<cfif ARGUMENTS.name neq "" AND structKeyExists(variables.field_types,ARGUMENTS.name)>
			<cfswitch expression="#variables.field_types[ARGUMENTS.name]#">
				<cfcase value="integer,float,double,bit,counter">
					<cfset local.res = rereplaceNOCase(ARGUMENTS.value,"[^\d,\.\-]","","all")>
					<cfif local.res eq "">
						<cfset local.res = "0">
					</cfif>
				</cfcase>
				<cfcase value="date,time,datetime">
					<cfset local.res = CreateODBCDateTime(ARGUMENTS.value)>
				</cfcase>
			</cfswitch>
		</cfif>
		<cfreturn local.res>
	</cffunction>
	<cffunction name="escape_name" access="public" returntype="string" hint="escape field name to prevent sql reserved words conflict">
		<cfargument name="data" type="string" required="yes">
		<cfreturn ARGUMENTS.data>
	</cffunction>
	<cffunction name="get_new_id" access="public" returntype="any">
		<cfreturn variables.last_inserted_id>
	</cffunction>
	
	<cffunction name="tables_list" access="public" returntype="struct" hint="get list of tables in the database">
		<cfthrow errorcode="99" message="Not implemented.">
	</cffunction>
	<cffunction name="fields_list" access="public" returntype="struct" hint="get fields struct for the table">
		<cfargument name="table" type="string" required="yes" hint="name of table in question">
		<cfargument name="id_field" type="string" required="no" default="" hint="the name of pky field">
		<cfset var local = structNew()>
		<cfset local.result = query("SELECT * FROM " & ARGUMENTS.table & " WHERE 1=0")>
		<cfset local.meta = getMetaData(local.result)>
		<cfset local.fields = arrayNew(1)>
		<cfif ARGUMENTS.id_field eq "">
			<cfset local.id = fields_pky(ARGUMENTS.table)>
		<cfelse>	
			<cfset local.id = ARGUMENTS.id_field>
		</cfif>	
		<cfloop from="1" to="#ArrayLen(local.meta)#" index="local.i">
			<cfif local.id neq local.meta[local.i].name>
			 	<cfset ArrayAppend(local.fields,local.meta[local.i].name)>
			</cfif>
		</cfloop>
		<cfset local.res = structNew()>
		<cfset local.res.fields = local.fields>
		<cfset local.res.key = local.id>
		<cfreturn local.res>
	</cffunction>
	<cffunction name="fields_pky" access="public" returntype="string" hint="get pky of the table">
		<cfargument name="table" type="string" required="yes" hint="name of table in question">
		<cfthrow errorcode="99" message="Not implemented. Define at least the primary key field in the constructor.">
	</cffunction>
	<cffunction name="auto_config_field_types" access="public" returntype="string" hint="Get the types of fields that are used.">
		<cfargument name="table" type="string" required="yes" hint="Table name in question">
		<cfset var local = structNew()>
		<cfquery datasource="#variables.connectionDSN#" name="local.res">
			SELECT * FROM #ARGUMENTS.table#
			WHERE 1=0
		</cfquery>
		<cfset local.meta = getMetaData(local.res)>
		<cfloop from="1" to="#arrayLen(local.meta)#" index="local.i">
			<cfset variables.field_types[local.meta[local.i].name] = local.meta[local.i].typeName>
		</cfloop>
	</cffunction>
</cfcomponent>
