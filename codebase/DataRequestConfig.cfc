<cfcomponent namespace="DataRequestConfig" hint="Manager of data request">
	<cfscript>
		variables.lineBreak = "#chr(13)##chr(10)#";
		variables.tab = "#chr(9)#";
		// array of filtering rules
		variables.filters = ArrayNew(1);	
		// ID or other element used for linking hierarchy
		variables.relation="";			
		// sorting field 
		variables.sort_by = ArrayNew(1);	
		// start of requested data
		variables.start=0;					
		// length of requested data
		variables.count=0;					
		
		variables.user = "";
		variables.version = "";
		
		// for render_sql
		// souce table or another source destination
		variables.source="";				
		// set of data, which need to be retrieved from source	
		variables.fieldset="";				
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="proto" type="any" required="no" hint="DataRequestConfig object, optional, if provided then new request object will copy all properties from provided one">
		<cfif isDefined("ARGUMENTS.proto")>
			<cfset copy(ARGUMENTS.proto)>
		<cfelse>
			<cfset variables.filters = ArrayNew(1)>
			<cfset variables.sort_by = ArrayNew(1)>
		</cfif>
		<cfreturn this>
	</cffunction>	
	<cffunction name="copy" access="public" returntype="void">
		<cfargument name="proto" type="any" required="yes">
		<cfset variables.filters	= ARGUMENTS.proto.get_filters()>
		<cfset variables.sort_by	= ARGUMENTS.proto.get_sort_by()>
		<cfset variables.count	= ARGUMENTS.proto.get_count()>
		<cfset variables.start	= ARGUMENTS.proto.get_start()>
		<cfset variables.source	= ARGUMENTS.proto.get_source()>
		<cfset variables.fieldset	= ARGUMENTS.proto.get_fieldset()>
		<cfset variables.relation	= ARGUMENTS.proto.get_relation()>
		<cfset variables.user	= ARGUMENTS.proto.get_user()>
		<cfset variables.version	= ARGUMENTS.proto.get_version()>
	</cffunction>
	
	<cffunction name="__toString" access="public" returntype="string">
		<cfset var local = structNew()>
		<cfset local.str="DataRequestConfig Object = [Source: #variables.source##variables.lineBreak#">
		<cfset local.str = local.str & "#variables.tab#Fieldset: #variables.fieldset##variables.lineBreak#">
		<cfif ArrayLen(variables.filters) eq 0>
			<cfset local.str = local.str & "#variables.tab#Where: [Empy array]#variables.lineBreak#">
		<cfelse>
			<cfset local.str = local.str & "#variables.tab#Where: [">
			<cfloop from="1" to="#ArrayLen(variables.filters)#" index="local.i">
				<cfif local.i neq ArrayLen(variables.filters)><cfset local.comma = ",#variables.lineBreak#"><cfelse><cfset local.comma = ""></cfif>
				<cfif isStruct(variables.filters)>
					<cfset local.str = local.str & "#variables.tab##variables.tab##variables.filters[local.i]["name"]# #variables.filters[local.i]["operation"]# #variables.filters[local.i]["value"]# #local.comma#">
				<cfelse>
					<cfset local.str = local.str & "#variables.tab##variables.tab##variables.filters[local.i]# #local.comma#">	
				</cfif>	
			</cfloop>
			<cfset local.str = local.str & "#variables.tab#]#variables.lineBreak#">
		</cfif>	
		<cfset local.str = local.str & "#variables.tab#Start:#variables.start##variables.lineBreak##variables.tab#Count:#variables.count##variables.lineBreak#">
		<cfif ArrayLen(variables.sort_by) eq 0>
			<cfset local.str = local.str & "#variables.tab#Order: [Empy array]#variables.lineBreak#">
		<cfelse>
			<cfset local.str = local.str & "#variables.tab#Order: [">
			<cfloop from="1" to="#ArrayLen(variables.sort_by)#" index="local.i">
				<cfif local.i neq ArrayLen(variables.sort_by)><cfset local.comma = ",#variables.lineBreak#"><cfelse><cfset local.comma = ""></cfif>
				<cfset local.str = local.str & "#variables.tab##variables.tab##variables.sort_by[local.i]["name"]# = #variables.filters[local.i]["direction"]# #local.comma#">
			</cfloop>
			<cfset local.str = local.str & "#variables.tab#]">
		</cfif>	
		<cfset local.str = local.str & "#variables.tab#Relation:#variables.relation##variables.lineBreak#">
		<cfset local.str = local.str & "#variables.tab#]">
		<cfreturn local.str>
	</cffunction>
	
	<cffunction name="get_filters" access="public" returntype="any">
		<cfreturn variables.filters>
	</cffunction>
	<cffunction name="get_fieldset" access="public" returntype="any">
		<cfreturn variables.fieldset>
	</cffunction>
	<cffunction name="get_source" access="public" returntype="any">
		<cfreturn variables.source>
	</cffunction>
	<cffunction name="get_sort_by" access="public" returntype="any">
		<cfreturn variables.sort_by>
	</cffunction>
	<cffunction name="get_sort_by_ref" access="public" returntype="any">
		<cfreturn variables.sort_by>
	</cffunction>
	<cffunction name="set_sort_by" access="public" returntype="void">
		<cfargument name="data" type="any" required="yes">
		<cfset variables.sort_by = ARGUMENTS.data>
	</cffunction>
	<cffunction name="get_start" access="public" returntype="any">
		<cfreturn variables.start>
	</cffunction>
	<cffunction name="get_count" access="public" returntype="any">
		<cfreturn variables.count>
	</cffunction>
	<cffunction name="get_relation" access="public" returntype="string">
		<cfreturn variables.relation>
	</cffunction>
	<cffunction name="get_user" access="public" returntype="any">
		<cfreturn variables.user>
	</cffunction>
	<cffunction name="get_version" access="public" returntype="any">
		<cfreturn variables.version>
	</cffunction>
	
	
	<cffunction name="set_sort" access="public" returntype="void">
		<cfargument name="field" type="string" required="no" default="">
		<cfargument name="order" type="string" required="no" default="">
		<cfset var local = structNew()>
		<cfif NOT len(ARGUMENTS.field) AND NOT len(ARGUMENTS.order)>
			<cfset variables.sort_by=ArrayNew(1)>
		<cfelse>
			<cfif ARGUMENTS.order eq "asc">
				<cfset ARGUMENTS.order="ASC">
			<cfelse>	
				<cfset ARGUMENTS.order="DESC">
			</cfif>
			<cfset local.st = structNew()>
			<cfset local.st["name"]=ARGUMENTS.field>
			<cfset local.st["direction"] = ARGUMENTS.order>
			<cfset ArrayAppend(variables.sort_by,local.st)>
		</cfif>
	</cffunction>
	
	<cffunction name="set_filter" access="public" returntype="void">
		<cfargument name="field" type="string" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfargument name="operation" type="string" required="no" default="">
		<cfset var local = structNew()>
		<cfset local.st["name"] = ARGUMENTS.field>
		<cfset local.st["value"]=ARGUMENTS.value>
		<cfset local.st["operation"] = ARGUMENTS.operation>
		<cfset ArrayAppend(variables.filters,local.st)>
	</cffunction>
		
	<cffunction name="set_filters" access="public" returntype="void">
		<cfargument name="data" type="array" required="yes">
		<cfset varisbles.filters=ARGUMENTS.data>
	</cffunction>
	<cffunction name="set_fieldset" access="public" returntype="void">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.fieldset = ARGUMENTS.value>
	</cffunction>
	<cffunction name="set_source" access="public" returntype="void">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.source = trim(ARGUMENTS.value)>
		<cfif NOT len(variables.source)>
			<cfthrow errorcode="99" message="Source of data can't be empty">
		</cfif> 
	</cffunction>
	<cffunction name="set_limit" access="public" returntype="void">
		<cfargument name="start" type="numeric" required="yes">
		<cfargument name="count" type="numeric" required="yes">
		<cfset variables.start = ARGUMENTS.start>
		<cfset variables.count = ARGUMENTS.count>
	</cffunction>
	<cffunction name="set_relation" access="public" returntype="void">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.relation = ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="set_user" access="public" returntype="any">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.user = ARGUMENTS.value>
	</cffunction>
	<cffunction name="set_version" access="public" returntype="any">
		<cfargument name="value" type="string" required="yes">
		<cfset variables.version = ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="parse_sql" access="public" returntype="void">
		<cfargument name="sql" type="string" required="yes">
		<cfset var local = structNew()>
		
		<cfset ARGUMENTS.sql = rereplaceNoCase(ARGUMENTS.sql,"[\s]+limit[\s,0-9]","","one")>
		<cfset local.data = split(ARGUMENTS.sql,"[\s]+from[\s]+",2)>
		<cfset set_fieldset(trim(rereplaceNoCase(local.data[1],"[\s]*select[\s]*","","one")))>
	  	<cfset local.table_data = split(local.data[2],"[\s]+where[\s]+",2)>
		<cfif ArrayLen(local.table_data) gt 1>
			<!--- //where construction exists --->
			<cfset set_source(trim(local.table_data[1]))>
  			<cfset local.where_data = split(local.table_data[2],"[\s]+order[\s]+by",2)>
  			<cfset ArrayAppend(variables.filters,trim(local.where_data[1]))>
  			<cfif ArrayLen(local.where_data) eq 1>
				<!--- //end of line detected--->
				<cfreturn> 
			</cfif> 
  			<cfset local.data = local.where_data[2]>
		<cfelse>
			<cfset local.table_data = split(local.table_data[1],"[\s]+order[\s]+by",2)>
  			<cfset set_source(trim(local.table_data[1]))>
  			<cfif ArrayLen(local.table_data) eq 1>
				<!--- //end of line detected--->
				<cfreturn> 
			</cfif> 
			<cfset local.data = local.table_data[2]>
		</cfif>

		<cfif len(trim(local.data))>
			<!--- //order by construction exists --->
			<cfloop list="#local.data#" index="local.srt">
				<cfset local.d = split(trim(local.srt),"[\s]+",2)>
				<cfset set_sort(local.d[1],local.d[2])>	
			</cfloop>
		</cfif>	
	</cffunction>
	<cffunction name="split" access="public" returntype="array">
		<cfargument name="str" type="string" required="yes">
		<cfargument name="regexp" type="string" required="yes">
		<cfargument name="limit" type="numeric" required="no" default="2">
		<cfset var local = structNew()>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.start = 1>
		<cfloop condition="true">
			<cfset local.match = refindNoCase(ARGUMENTS.regexp,ARGUMENTS.str,local.start,true)>
			<cfif local.match.pos[1] AND (ARGUMENTS.limit eq -1 OR ARGUMENTS.limit gt ArrayLen(local.ar)+1)>
				<cfset local.s = mid(ARGUMENTS.str,local.start,local.match.pos[1]-local.start)>
				<cfset arrayAppend(local.ar,local.s)>
				<cfset local.start = local.match.pos[1]+local.match.len[1]>
			<cfelse>
				<cfset local.s = right(ARGUMENTS.str,len(ARGUMENTS.str)-local.start+1)>
				<cfset arrayAppend(local.ar,local.s)>
				<cfbreak>	
			</cfif>
		</cfloop>
		<Cfreturn local.ar>
	</cffunction>
</cfcomponent>