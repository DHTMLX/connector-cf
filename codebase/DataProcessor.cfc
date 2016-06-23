<cfcomponent namespace="DataProcessor" hint="Base DataProcessor handling">
	<cfscript>
		//Connector instance
		variables.connector = "";
		//DataConfig instance
		variables.config = "";
		//DataRequestConfig instance
		variables._request = "";
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="Constructor">
		<cfargument name="connector" type="any" required="yes" hint="Connector object">
		<cfargument name="config" type="any" required="yes" hint="DataConfig object">
		<cfargument name="_request" type="any" required="yes" hint="DataRequestConfig object">	
		<cfset variables.connector = ARGUMENTS.connector>
		<cfset variables.config = ARGUMENTS.config>
		<cfset variables._request = ARGUMENTS._request>
		<cfreturn this>
	</cffunction>
	<cffunction name="name_data" access="public" returntype="string" hint="Convert incoming data name to valid db name. Redirect to Connector.name_data by default. Return related db_name">
		<cfargument name="data" type="string" required="yes" hint="data name from incoming request">
		<cfreturn ARGUMENTS.data>
	</cffunction>
	<cffunction name="first_loop_form_fields" returntype="string" hint="Get the list of the form fields names that will be first in the loop. The order is different at evey call so it is required.">
		<Cfreturn "">
	</cffunction>
	<!----------------------- ---------------------- -------------------------------->
	<!----------------------- ---------------------- -------------------------------->
	<!----------------------- ---------------------- -------------------------------->

	<cffunction name="get_post_values" access="public" returntype="struct" hint="retrieve data from incoming request and normalize it. Return hash of data">
		<cfargument name="ids" type="array" required="yes" hint="array of extected IDs">
		<cfset var local = structNew()>
		
		<!--- first order loop --->
		<cfset local.flds = first_loop_form_fields()>
		<cfset local.tm = ArrayNew(1)>
		<cfset local.data = structNew()> 
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.ids)#" index="local.i">
			<cfset local.data[ARGUMENTS.ids[local.i]]=structNew()>
		</cfloop>
		<cfloop from="1" to="2" index="local.i">
			<cfloop collection="#FORM#" item="local.key">
					<cfset local.value = FORM[local.key]>
					<cfset local.details=ListToArray(local.key,"_")>
					<cfif ArrayLen(local.details) gt  1>
						<cfset local.name2 = local.details[1]>
						<cfset ArrayDeleteAt(local.details,1)>
						<cfif (local.i eq 1 AND ListFindNoCase(local.flds,ArrayToList(local.details,"_"))) OR (local.i eq 2 AND NOT ListFindNoCase(local.flds,ArrayToList(local.details,"_")))>
							<cfset local.name=name_data(ArrayToList(local.details,"_"))>
							<cfset local.data[local.name2][local.name]=local.value>
						</cfif>	
					</cfif>
			</cfloop> 
		</cfloop>
		<cfreturn local.data>
	</cffunction>
	
	<cffunction name="process" access="public" returntype="void" hint="process incoming request ( save|update|delete )">
		<cfset var local = structNew()>
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="DataProcessor object initialized">
			<cfinvokeargument name="data" value="#FORM#">
		</cfinvoke>
		
		<cfset local.results=ArrayNew(1)>
		<cfif NOT isDefined("FORM.ids")>
			<cfthrow errorcode="99" message="Incorrect incoming data, ID of incoming records not recognized">
		</cfif>	
		<cfset local.ids=ListToArray(FORM.ids,",")>
		<cfset local.rows_data = get_post_values(local.ids)>
		<cfset local.failed=false>
		<cftry>
			<cfif variables.connector.sql.is_global_transaction()>
				<cfset variables.connector.sql.begin_transaction()>
			</cfif>
			<cfloop from="1" to="#ArrayLen(local.ids)#" index="local.i">
				<cfset local.rid = local.ids[local.i]>
				<cfinvoke component="LogMaster" method="do_log">
					<cfinvokeargument name="message" value="Row data ""#local.rid#""">
					<cfinvokeargument name="data" value="#local.rows_data[local.rid]#">
				</cfinvoke>
				<cfif NOT structKeyExists(FORM,"#local.rid#_!nativeeditor_status")>
					<cfthrow errorcode="99" message="Status of record [#local.rid#] not found in incoming request">
				</cfif>	
				<cfset local.status = FORM["#local.rid#_!nativeeditor_status"]>
				<cfset local.action=CreateObject("component","DataAction").init(local.status,local.rid,local.rows_data[local.rid])>
				<cfset ArrayAppend(local.results,local.action)>
				<cfset inner_process(local.action)>
			</cfloop>
		<cfcatch>
			<cfinvoke component="LogMaster" method="do_log">
				<cfinvokeargument name="message" value="Cfcatch_message: #cfcatch.message#">
				<cfinvokeargument name="data" value="#cfcatch.TagContext[1].Template# (Line: #cfcatch.TagContext[1].Line#)">
			</cfinvoke>
			<cfset local.failed=true>
		</cfcatch>	
		</cftry>
		
		<cfif variables.connector.sql.is_global_transaction()>
			<cfif NOT local.failed>
				<cfloop from="1" to="#ArrayLen(local.results)#" index="local.i">
					<cfif local.results[local.i].get_status() eq "error" OR local.results[local.i].get_status() eq "invalid">
						<cfset local.failed=true>
						<cfbreak>
					</cfif>
				</cfloop>	
			</cfif>
			<cfif local.failed>
				<cfloop from="1" to="#ArrayLen(local.results)#" index="local.i">
					<cfset local.results[local.i].error()>
				</cfloop>
				<cfset variables.connector.sql.rollback_transaction()>
			<cfelse>
				<cfset variables.connector.sql.commit_transaction()>
			</cfif>	
		</cfif>
		<cfset output_as_xml(local.results)>
	</cffunction>
	

	<cffunction name="status_to_mode" access="public" returntype="string" hint="converts status string to the inner mode name. Return inner mode name">
		<cfargument name="status" type="string" required="yes" hint="external status string"> 
		<cfswitch expression="#ARGUMENTS.status#">
			<cfcase value="updated">
				<cfreturn "Update">
			</cfcase>	
			<cfcase value="inserted">
				<cfreturn "Insert">
			</cfcase>	
			<cfcase value="deleted">
				<cfreturn "Delete">
			</cfcase>	
			<cfdefaultcase>
				<cfreturn ARGUMENTS.status>
			</cfdefaultcase>		
		</cfswitch>	
	</cffunction>
	
	<cffunction name="inner_process" access="public" returntype="any" hint="process data updated request received. Return DataAction object with details of processing">
		<cfargument name="action" type="any" required="yes" hint="DataAction object">  
		<cfset var local =structNew()>
		
		<cfif variables.connector.sql.is_record_transaction()>
			<cfset variables.connector.sql.begin_transaction()>
		</cfif>
		<cftry>
			<cfset local.mode = status_to_mode(ARGUMENTS.action.get_status())>
			<cfif NOT variables.connector.access.check(local.mode)>
				<cfinvoke component="LogMaster" method="do_log">
					<cfinvokeargument name="message" value="Access control: #local.mode# operation blocked">
				</cfinvoke>
				<cfset ARGUMENTS.action.error()>
			<cfelse>
				<cfset local.check = variables.connector.event.trigger("beforeProcessing",ARGUMENTS.action)>
				<cfif NOT ARGUMENTS.action.is_ready()>
					<cfset check_exts(ARGUMENTS.action,local.mode)>
				</cfif>	
				
				<cfset local.check = variables.connector.event.trigger("afterProcessing",ARGUMENTS.action)>
			</cfif>
			<cfcatch>
				<cfdump var="#cfcatch#"><cfabort>
				<cfinvoke component="LogMaster" method="do_log">
					<cfinvokeargument name="message" value="Cfcatch_message: #cfcatch.message#">
					<cfinvokeargument name="data" value="#cfcatch.TagContext[1].Template# (Line: #cfcatch.TagContext[1].Line#)">
				</cfinvoke>
				<cfset action.set_status("error")>
			</cfcatch>
		</cftry>
		<cfif variables.connector.sql.is_record_transaction()>
			<cfif ARGUMENTS.action.get_status() eq "error" OR  ARGUMENTS.action.get_status() eq "invalid">
				<cfset variables.connector.sql.rollback_transaction()>
			<cfelse>
				<cfset variables.connector.sql.commit_transaction()>
			</cfif>	
		</cfif>
		<cfreturn ARGUMENTS.action>
	</cffunction>

	<cffunction name="check_exts" access="public" returntype="void" hint="check if some event intercepts processing, send data to DataWrapper in other case">
		<cfargument name="action" type="any" required="yes" hint="DataAction object"> 
		<cfargument name="mode" type="string" required="yes" hint="name of inner mode ( will be used to generate event names )">  
	
		<cfset var local = structNew()>
		<cfset local.old_config = CreateObjecT("component","DataConfig").init(variables.config)>
		<cfset local.method=ArrayNew(1)>
		<cfset variables.connector.event.trigger("before"& ARGUMENTS.mode,ARGUMENTS.action)>
		<cfif ARGUMENTS.action.is_ready()>
			<cfinvoke component="LogMaster" method="do_log">
				<cfinvokeargument name="message" value="Event code for #ARGUMENTS.mode# processed">
			</cfinvoke>
		<cfelse>
			<!--- check if custom sql defined --->
			<cfset local.sql = variables.connector.sql.get_sql(ARGUMENTS.mode,ARGUMENTS.action)>
			<cfif len(local.sql)>
				<cfset variables.connector.sql.query(local.sql)>
			<cfelse>
				<cfset ARGUMENTS.action.sync_config(variables.config)>
				<cfset ArrayAppend(local.method,variables.connector.sql)>
				<cfset ArrayAppend(local.method,"do_" & ARGUMENTS.mode)>
				<cfif NOT IsCustomFunction(evaluate('local.method[1].#local.method[2]#'))>
					<cfthrow errorcode="99" message="Unknown dataprocessing action: #ARGUMENTS.mode#">
				</cfif>	
				<cfset evaluate("local.method[1].#local.method[2]#(ARGUMENTS.action,variables._request)")>
			</cfif>
		</cfif>
		<cfset variables.connector.event.trigger("after" & ARGUMENTS.mode,ARGUMENTs.action)>
		<cfset variables.config = local.old_config>
	</cffunction>	
	
	<cffunction name="output_as_xml" access="public" returntype="void" hint="output xml response for dataprocessor">
		<cfargument name="results" type="array" required="yes" hint="array of DataAction objects">
		<cfset var local=structNew()>
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="Edit operation finished">
			<cfinvokeargument name="data" value="#ARGUMENTS.results#">
		</cfinvoke>
		<cfcontent type="text/xml;charset=UTF-8"><cfoutput><?xml version='1.0' ?><data>
		<cfloop from="1" to="#ArrayLen(ARGUMENTs.results)#" index="local.i">
			#ARGUMENTS.results[local.i].to_xml()#
		</cfloop>
		</data>
		</cfoutput>
	</cffunction>
</cfcomponent>
