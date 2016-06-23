<cfcomponent namespace="OutputWriter">
	<cfscript>
		variables.start = "";
		variables.end = "";
		variables.type = "xml";
		variables.encoding = "UTF-8";
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="start" type="string" required="yes">
		<cfargument name="end" type="string" required="no" default="">
		<cfargument name="encoding" type="string" required="no" default="">
		<cfset variables.start = ARGUMENTS.start>
		<cfset variables.end = ARGUMENTS.end>
		<cfif ARGUMENTS.encoding neq "">
			<cfset variables.encoding = ARGUMENTS.encoding>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="add" access="public" returntype="void">
		<cfargument name="add" type="string" required="yes">
		<cfset variables.start = variables.start & ARGUMENTS.add>
	</cffunction>
	<cffunction name="reset" access="public" returntype="void">
		<cfset variables.start = "">
		<cfset variables.end = "">
	</cffunction>
	<cffunction name="set_type" access="public" returntype="void">
		<cfargument name="type" type="string" required="yes">
		<cfset variables.type = ARGUMENTS.type>
	</cffunction>
	<cffunction name="output" access="public" returntype="void">
		<cfargument name="name" type="string" required="no" default="">
		<cfargument name="inline" type="boolean" required="no" default="true">
		<cfif variables.type eq "xml">
			<cfcontent type="text/xml;charset=#variables.encoding#" reset="yes"><Cfoutput>#variables.start##variables.end#</Cfoutput>
		<cfelse>
			<cfcontent type="text/html;charset=#variables.encoding#" reset="yes"><Cfoutput>#variables.start##variables.end#</Cfoutput>	
		</cfif>
	</cffunction>
	<cffunction name="get_output" access="public" returntype="string">
		<cfreturn variables.start & variables.end>
	</cffunction>
</cfcomponent>
	