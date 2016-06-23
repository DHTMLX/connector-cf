<cfcomponent namespace="FileSystemResult">
	<cfscript>
		variables.files = QueryNew("filename,full_filename,size,extention,name,date,relation_id,safe_name,is_folder");
	</cfscript>
	<cffunction name="init" access="public" returntype="any">
		<cfreturn this>
	</cffunction>
	<cffunction name="get_files" access="public" returntype="query">
		<cfreturn variables.files>
	</cffunction>
	<cffunction name="addFile" access="public" returntype="void" hint="add record to output list">
		<cfargument name="file" type="struct" required="yes">
		<cfset var local = structNew()>
		<cfset QueryAddRow(variables.files)>
		<cfloop collection="#ARGUMENTS.file#" item="local.fld">
			<cfset QuerySetCell(variables.files,local.fld,ARGUMENTS.file[local.fld])>
		</cfloop>	
	</cffunction>	

	<cffunction name="sort" access="public" returntype="query" hint=" sorts records under ARGUMENTS.sort array">
		<cfargument name="sort" type="array" required="yes">
		<cfargument name="data" type="array" required="yes">
		<cfset var local = structNew()>
		<cfif variables.files.recordCount eq 0>
			<cfreturn variables.files>
		</cfif>
		<cfset local.sort = "">
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.sort)#" index="local.i">
			<cfif ARGUMENTS.sort[local.i].name eq "date">
				<cfset local.sort = ListAppend(local.sort,"date_modified" & " " & ARGUMENTS.sort[local.i].direction)>
				<cfset QueryAddColumn(variables.files,"date_modified","Date",ListToArray(ValueList(variables.files.date)))>
			<cfelse>
				<cfset local.sort = ListAppend(local.sort,ARGUMENTS.sort[local.i].name & " " & ARGUMENTS.sort[local.i].direction)>
			</cfif>	
		</cfloop>
		<cfif len(local.sort)>
			<cfquery dbtype="query" name="variables.files">
				SELECT * 
				FROM variables.files
				ORDER BY #local.sort#
			</cfquery>
		</cfif>	
		<cfreturn variables.files>
	</cffunction>
</cfcomponent>
