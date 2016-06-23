<cfcomponent namespace="LogMaster" hint="Controls error and debug logging.">
	<cfscript>
		variables.lineBreak = "#chr(13)##chr(10)#";
		variables.tab = "#chr(9)#";
		variables.prefix = "Log: ";
		if (not isDefined("request.LogMaster_static")){
			//log file
			request.LogMaster_static._logFile = "";
			// output error infor to client flag
			request.LogMaster_static._output = false;
			//all messages generated for current request
			request.LogMaster_static._session = "";
		}	
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="log_details" access="public" returntype="string" hint="convert array to string representation ( it is a bit more readable than var_dump ). Return: string with array description">
		<cfargument name="data" type="any" required="yes" hint="data object">
		<cfargument name="pref" type="string" required="no" default="" hint="Prefix string, used for formating, optional">
		<cfset var local = structNew()>
		<cfif isArray(ARGUMENTS.data)>
			<cfset local.str = ArrayNew(1)>
			<cfloop from="1" to="#ArrayLen(ARGUMENTS.data)#" index="local.k">
				<cfset local.details = log_details(ARGUMENTS.data[local.k],ARGUMENTS.pref & variables.tab)>
				<cfset arrayAppend(local.str,ARGUMENTS.pref & "[" & local.k & "] = " & trim(local.details))>
			</cfloop>
			<cfif ArrayLen(local.str) eq 0>
				<cfset ArrayAppend(local.str,"[empty array]")>
			</cfif>
			<cfreturn ArrayToList(local.str,variables.lineBreak)>
		<cfelseif isStruct(ARGUMENTS.data) ANd (not isDefined("ARGUMENTS.data.__toString") OR not IsCustomFunction(ARGUMENTS.data.__toString))>
			<cfset local.str = ArrayNew(1)>
			<cfloop collection="#ARGUMENTS.data#" item="local.k">
				<cfset local.details = log_details(ARGUMENTS.data[local.k],ARGUMENTS.pref & variables.tab)>
				<cfif findNoCase(variables.lineBreak,local.details)>
					<cfset ArrayAppend(local.str,variables.lineBreak)>
				</cfif>
				<cfset arrayAppend(local.str,ARGUMENTS.pref & "[" & local.k & "] = " & trim(local.details))>
			</cfloop>
			<cfif ArrayLen(local.str) eq 0>
				<cfset ArrayAppend(local.str,"[empty struct]")>
			</cfif>
			<cfreturn ArrayToList(local.str,variables.lineBreak)>
   		<cfelseif isObject(ARGUMENTS.data)>
			<cfif isDefined("ARGUMENTS.data.__toString") AND IsCustomFunction(ARGUMENTS.data.__toString)>
				<cfreturn ARGUMENTS.data.__toString()>
			<cfelse>
				<cfreturn "[object]">
			</cfif>	
		</cfif>	
   		<cfreturn ARGUMENTS.data>
	</cffunction>
	
	<cffunction name="do_log" access="public" returntype="void" hint="put record in log">
		<cfargument name="message" type="string" required="no" default="" hint="string with log info, optional">
		<cfargument name="data" type="any" required="no" hint="data object, which will be added to log, optional">
		<cfset var local = structNew()>
		<cfif len(request.LogMaster_static._logFile)>
			<cfif len(ARGUMENTS.message)>
				<cfset local.message = ARGUMENTS.message>
			<cfelse>
				<cfset local.message = "">	
			</cfif>	
			<cfif isDefined("ARGUMENTS.data")>
				<cfset local.data = log_details(ARGUMENTS.data,variables.tab)>
				<cfif trim(local.data) neq "">
					<cfset local.message = local.message & ": " & variables.lineBreak & local.data & variables.lineBreak>
				</cfif> 
			 </cfif>
			<cfset request.LogMaster_static._session = request.LogMaster_static._session & local.message>
			<cfif not fileExists(request.LogMaster_static._logFile)>
				<cffile action="write" file="#request.LogMaster_static._logFile#" output="#local.message#" addnewline="yes">
			<cfelse>
				<cffile action="append" file="#request.LogMaster_static._logFile#" output="#local.message#" addnewline="yes">
			</cfif> 	
   		</cfif>
	</cffunction>
	
	<cffunction name="get_session_log" access="public" returntype="string" hint="get logs for current request. Return: string, which contains all log messages generated for current request">
		<cfreturn request.LogMaster_static._session>
	</cffunction>
	
	<cffunction name="exception_log" access="remote" returntype="void" hint="exception handler, used as default reaction on any error - show execution log and stop processing">
		<cfargument name="error" type="struct" required="yes" hint="error data from CF server">
		<cftry>
			<cfif isDefined("ARGUMENTS.error.RootCause.ErrNumber")>
				<!--- exception --->
				<cfset do_log("!!!Uncaught Exception#variables.lineBreak#Code: " & ARGUMENTS.error.RootCause.ErrNumber & "#variables.lineBreak#Message: " & ARGUMENTS.error.RootCause.Message& " " & ARGUMENTS.error.RootCause.Detail & "#variables.lineBreak#" & ARGUMENTS.error.RootCause.TagContext[1].Template & " on line " & ARGUMENTS.error.RootCause.TagContext[1].Line)>		
			<cfelse>
				<!--- error --->	
				<cfset do_log(ARGUMENTS.error.message & ": " & ARGUMENTS.error.RootCause.TagContext[1].Template & " on line " & ARGUMENTS.error.RootCause.TagContext[1].Line)>
			</cfif>
			<cfcontent reset="yes" type="text/html">
			<cfif request.LogMaster_static._output>
				<cfoutput><pre><xmp>#variables.lineBreak##xmlFormat(get_session_log())##variables.lineBreak#</xmp></pre></cfoutput>
			<cfelse>
				<cfoutput>#ARGUMENTS.error.message#<br />#ARGUMENTS.error.RootCause.TagContext[1].Template# on line #ARGUMENTS.error.RootCause.TagContext[1].Line#</cfoutput>	
			</cfif>
		<cfcatch></cfcatch>
		</cftry>
		<Cfabort>
	</cffunction>
	
	<cffunction name="enable_log" access="public" returntype="void" hint="enable logging">
		<cfargument name="vars" type="struct" required="yes">
		<cfargument name="path" type="string" required="no" default="" hint="path to the log file, if boolean false provided as value - logging will be disabled">
		<cfargument name="output" type="boolean" required="no" default="False">
		<cfset request.LogMaster_static._logFile = ARGUMENTS.path>
		<cfset request.LogMaster_static._output = ARGUMENTS.output>
		<cfif Len(request.LogMaster_static._logFile)>
			<cferror type="exception" exception="any" template="#CGI.SCRIPT_NAME#"> 
			<cferror type="request" exception="any" template="#CGI.SCRIPT_NAME#"> 
			<cfset do_log("====================================#variables.lineBreak#Log started, " & DateFormat(now(),"dd/mm/yyyy")&" " & TimeFormat(now(),"hh:mm:sstt") & "#variables.lineBreak#====================================")>
			
			<!--- error occured --->
			<cfif structKeyExists(ARGUMENTS.vars,"error")>
				<cfset exception_log(ARGUMENTS.vars.error)>
			</cfif>
		</cfif>
	</cffunction>
</cfcomponent>
