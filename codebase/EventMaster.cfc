<!---  ----------------------------------------------------------------------------
	Inner classes, which do common tasks. No one of them is purposed for direct usage. 
 ----------------------------------------------------------------------------  --->
<cfcomponent namespace="EventMaster" hint="Class which allows to assign|fire events.">
	<!--- hash of event handlers --->
	<cfscript>
		variables.Events = structNew();
		if (not isDefined("request.EventMaster_static")){
			request.EventMaster_static = structNew();
		};	
	</cfscript>	
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor">
		<cfreturn this>
	</cffunction>
	<cffunction name="exist" access="public" returntype="boolean" hint="Method check if event with such name already exists. Return: true if event with such name registered, false otherwise">
		<cfargument name="name" type="string" required="yes" hint="name of event, case non-sensitive">
		<cfif structKeyExists(variables.Events,ARGUMENTS.name) AND ArrayLen(variables.Events[ARGUMENTS.name])>
			<cfreturn true>
		<cfelse>
			<Cfreturn false>	
		</cfif>
	</cffunction>
	
	<cffunction name="attach" access="public" returntype="void" hint="Attach custom code to event. Only on event handler can be attached in the same time. If new event handler attached - old will be detached.">
		<cfargument name="name" type="string" required="yes" hint="name of event, case non-sensitive">
		<cfargument name="method" type="any" required="yes" hint="function which will be attached. You can use array(class, method) if you want to attach the method of the class.">
		<cfif NOT structKeyExists(variables.Events,ARGUMENTS.name)>
			<cfset variables.Events[ARGUMENTS.name] = ArrayNew(1)>
		</cfif>
		<cfset ArrayAppend(variables.Events[ARGUMENTS.name],ARGUMENTS.method)>
	</cffunction>

	<cffunction name="attach_static" access="public" returntype="void" hint="Attach custom code to event. Only on event handler can be attached in the same time. If new event handler attached - old will be detached.">
		<cfargument name="name" type="string" required="yes" hint="name of event, case non-sensitive">
		<cfargument name="method" type="any" required="yes" hint="function which will be attached. You can use array(class, method) if you want to attach the method of the class.">
		<cfif NOT structKeyExists(request.EventMaster_static,ARGUMENTS.name)>
			<cfset request.EventMaster_static[ARGUMENTS.name] = ArrayNew(1)>
		</cfif>
		<cfset ArrayAppend(request.EventMaster_static[ARGUMENTS.name],ARGUMENTS.method)>
	</cffunction>
	
	<cffunction name="detach" access="public" returntype="void" hint="Detach code from event">
		<cfargument name="name" type="string" required="yes" hint="name of event, case non-sensitive">
		<cfif structKeyExists(variables.Events,ARGUMENTS.name)>
			<cfset structDelete(variables.Events,ARGUMENTS.name)>
		</cfif>	
	</cffunction>

	<!--- value which will be provided as argument for event function, you can provide multiple data arguments, method accepts variable number of parameters--->
	<cffunction name="trigger" access="public" returntype="boolean" hint="Trigger event. Return: true if event handler was not assigned , result of event hangler otherwise">
		<cfargument name="name" type="string" required="yes" hint="name of event, case non-sensitive">
		<cfset var local = structNew()>
		
		<cfif structKeyExists(variables.Events,ARGUMENTS.name)>
			<cfset local.args = "">
			<cfset local.i = 2>
			<cfloop condition="true">
				<cfif structKeyExists(ARGUMENTS,toString(local.i))>
					<cfset local.args = ListAppend(local.args,"ARGUMENTS[#local.i#]")>
				<cfelse>
					<cfbreak>	
				</cfif>
				<cfset local.i = local.i+1>
			</cfloop>
			<cfloop from="1" to="#ArrayLen(variables.Events[ARGUMENTS.name])#"  index="local.i">
				<cfset local.method = variables.Events[ARGUMENTS.name][local.i]>
				
				<cfif isArray(local.method) AND NOT IsCustomFunction(evaluate('local.method[1].#local.method[2]#'))>
					<cfthrow message="Incorrect method assigned to event: #local.method[2]#" errorcode="99">
				</cfif>
				<cfif NOT isArray(local.method) AND NOT IsCustomFunction(local.method)>
					<cfthrow message="Incorrect function assigned to event: #local.method#" errorcode="99">
				</cfif>
				<cfif isArray(local.method)>
					<cfset evaluate("local.method[1].#local.method[2]#(#local.args#)")>
				<cfelse>
					<cfset evaluate("local.method(#local.args#)")>
				</cfif>		
			</cfloop>
		</cfif>	
		<cfreturn true>
	</cffunction>
	
	<cffunction name="trigger_static" access="public" returntype="boolean" hint="Trigger event. Return: true if event handler was not assigned , result of event hangler otherwise">
		<cfargument name="name" type="string" required="yes" hint="name of event, case non-sensitive">
		<cfset var local = structNew()>
		<cfif structKeyExists(request.EventMaster_static,ARGUMENTS.name)>
			<cfset local.args = "">
			<cfloop collection="#arguments#" item="local.arg">
				<cfif local.arg neq "name" AND isNumeric(local.arg)>
					<cfset local.args = ListAppend(local.args,"ARGUMENTS[#local.arg#]")>
				</cfif>
			</cfloop>
			<cfloop from="1" to="#ArrayLen(request.EventMaster_static[ARGUMENTS.name])#"  index="local.i">
				<cfset local.method = request.EventMaster_static[ARGUMENTS.name][local.i]>
				<cfif isArray(local.method) AND NOT IsCustomFunction(evaluate('local.method[1].#local.method[2]#'))>
					<cfthrow message="Incorrect method assigned to event: #local.method[2]#" errorcode="99">
				</cfif>
				<cfif NOT isArray(local.method) AND NOT IsCustomFunction(local.method)>
					<cfthrow message="Incorrect function assigned to event: #local.method#" errorcode="99">
				</cfif>
				<cfif isArray(local.method)>
					<cfset evaluate("local.method[1].#local.method[2]#(#local.args#)")>
				<cfelse>
					<cfset evaluate("local.method(#args#)")>
				</cfif>		
			</cfloop>
		</cfif>	
		<cfreturn true>
	</cffunction>
</cfcomponent>