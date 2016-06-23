<cfcomponent namespace="DataAction" hint="contain all info related to action and controls customizaton">
	<cfscript>
		//cuurent status of record
		variables.status="";
		//id of record
		variables.id="";
		//data hash of record
		variables.data=structNew();
		//hash of extra data , attached to record
		variables.userdata="";
		//new id value , after operation executed
		variables.nid="";
		//custom output to client side code
		variables.output="";
		//hash of custtom attributes 
		variables.attrs="";
		//flag of operation's execution
		variables.ready="";
		//array of added fields 
		variables.addf="";
		//array of deleted fields
		variables.delf="";
	</cfscript>
	 
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="status" type="string" required="yes" hint="current operation status">
		<cfargument name="id" type="string" required="yes" hint="record id">
		<cfargument name="data" type="struct" required="yes" hint="hash of data">
		<cfset variables.status=ARGUMENTS.status>
		<cfset variables.id=ARGUMENTs.id>
		<cfset variables.data=ARGUMENTS.data>
		<cfset variables.nid=ARGUMENTS.id>
		<cfset variables.output="">
		<cfset variables.attrs=structNew()>
		<cfset variables.ready=false>
		<cfset variables.addf=ArrayNew(1)>
		<cfset variables.delf=ArrayNew(1)>
		<cfreturn this>
	</cffunction>
	<cffunction name="dump" access="public" returntype="any" hint="dump. Debug function to get object private properties.">
		<cfset var tmp = "">
		<cfsavecontent variable="tmp">
			<Cfdump var="#variables#">
		</cfsavecontent>
		<cfreturn tmp>
	</cffunction>
	<cffunction name="add_field" access="public" returntype="void" hint="add custom field and value to DB operation">
		<cfargument name="name" type="string" required="yes" hint="name of field which will be added to DB operation">
		<cfargument name="value" type="string" required="yes" hint="value which will be used for related field in DB operation">
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="Adding field: #ARGUMENTS.name# with value: #ARGUMENTS.value#">
		</cfinvoke>
		<cfset variables.data[ARGUMENTS.name]=ARGUMENTS.value>
		<cfset ArrayAppend(variables.addf,ARGUMENTS.name)>
	</cffunction>
	
	<cffunction name="remove_field" access="public" returntype="void" hint="remove field from DB operation">
		<cfargument name="name" type="string" required="yes" hint="name of field which will be removed from DB operation">
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="Removing field: #ARGUMENTS.name#">
		</cfinvoke>
		<cfset ArrayAppend(variables.delf,ARGUMENTs.name)>
	</cffunction>	

	<cffunction name="sync_config" access="public" returntype="void" hint="sync field configuration with external object">
		<cfargument name="slave" type="any" required="yes" hint="SQLMaster object">
		<Cfset var local = structNew()>
		<cfloop from="1" to="#ArrayLen(variables.addf)#" index="local.i">
			<cfset ARGUMENTS.slave.add_field(variables.addf[local.i])>
		</cfloop>
		<cfloop from="1" to="#ArrayLen(variables.delf)#" index="local.i">
			<cfset ARGUMENTS.slave.remove_field(variables.delf[local.i])>
		</cfloop>
	</cffunction>
	
	<cffunction name="get_value" access="public" returntype="string" hint="get value of some record's propery. Return: value of related property">
		<cfargument name="name" type="string" required="yes" hint="name of record's property ( name of db field or alias )">
		<cfif NOT structKeyExists(variables.data,ARGUMENTs.name)>
			<cfinvoke component="LogMaster" method="do_log">
				<cfinvokeargument name="message" value="Incorrect field name used: #ARGUMENTS.name#">
				<cfinvokeargument name="data" value="#variables.data#">
			</cfinvoke>
			<cfreturn "">
		</cfif>
		<cfreturn variables.data[ARGUMENTS.name]>
	</cffunction>	
	
	<cffunction name="set_value" access="public" returntype="void" hint="set value of some record's propery">
		<cfargument name="name" type="string" required="yes" hint="name of record's property ( name of db field or alias )">
		<cfargument name="value" type="string" required="yes" hint="value of related property">
		<cfinvoke component="LogMaster" method="do_log">
			<cfinvokeargument name="message" value="Change value of: #ARGUMENTS.name# as: #ARGUMENTS.value#">
		</cfinvoke>
		<cfset variables.data[ARGUMENTS.name]=ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="get_data" access="public" returntype="struct" hint="get hash of data properties. Return: hash of data properties">
		<cfreturn variables.data>	
	</cffunction>
	
	<cffunction name="get_userdata_value" access="public" returntype="string" hint="get some extra info attached to record, deprecated, exists just for backward compatibility, you can use set_value instead of it. Return: value of related userdata property">
		<cfargument name="name" type="string" required="yes" hint="name of userdata property">
		<cfreturn get_value(ARGUMENTS.name)>
	</cffunction>
	
	<cffunction name="set_userdata_value" access="public" returntype="void" hint="set some extra info attached to record, deprecated, exists just for backward compatibility, you can use get_value instead of it">
		<cfargument name="name" type="string" required="yes" hint="name of userdata property">
		<cfargument name="value" type="string" required="yes" hint="value of userdata property">
		<cfset set_value(ARGUMENTS.name,ARGUMENTS.value)>
	</cffunction>

	<cffunction name="get_status" access="public" returntype="string" hint="get current status of record. Return: string with status value">
		<cfreturn variables.status>
	</cffunction>
	
	<cffunction name="set_status" access="public" returntype="void" hint="assign new status to the record">
		<cfargument name="status" type="string" required="yes" hint="new status value">
		<cfset variables.status = ARGUMENTS.status>
	</cffunction>
	
	<cffunction name="get_id" access="public" returntype="string" hint="get id of current record. Return: id of record">
		<cfreturn variables.id>
	</cffunction>

	<cffunction name="set_response_text" access="public" returntype="void" hint="sets custom response text, can be accessed through defineAction on client side. Text wrapped in CDATA, so no extra escaping necessary">
		<cfargument name="text" type="string" required="yes" hint="custom response text">
		<cfset set_response_xml("<![CDATA[" & ARGUMENTS.text & "]]>")>
	</cffunction>

	<cffunction name="set_response_xml" access="public" returntype="void" hint="sets custom response xml, can be accessed through defineAction on client side">
		<cfargument name="text" type="string" required="yes" hint="string with XML data">
		<cfset variables.output=ARGUMENTS.text>
	</cffunction>

	<cffunction name="set_response_attribute" access="public" returntype="void" hint="sets custom response attributes, can be accessed through defineAction on client side">
		<cfargument name="name" type="string" required="yes" hint="name of custom attribute">
		<cfargument name="value" type="string" required="yes" hint="value of custom attribute">
		<cfset attrs[ARGUMENTS.name]=ARGUMENTS.value>	
	</cffunction>

	<cffunction name="is_ready" access="public" returntype="boolean" hint="check if action finished. Return: true if action finished, false otherwise">
		<cfreturn variables.ready>
	</cffunction>	
	
	<cffunction name="get_new_id" access="public" returntype="string" hint="return new id value, equal to original ID normally, after insert operation - value assigned for new DB record. Return: new id value">
		<cfreturn variables.nid>
	</cffunction>

	<cffunction name="error" access="public" returntype="void" hint="set result of operation as error">
		<cfset variables.status="error">
		<cfset variables.ready=true>
	</cffunction>
	
	<cffunction name="invalid" access="public" returntype="void" hint="set result of operation as invalid">
		<cfset variables.status="invalid">
		<cfset variables.ready=true>
	</cffunction>

	<cffunction name="success" access="public" returntype="void" hint="confirm successful opeation execution">
		<cfargument name="id" type="string" required="no" default="" hint="new id value, optional">
		<cfif len(ARGUMENTS.id)>
			<cfset variables.nid = ARGUMENTS.id>
		</cfif>	
		<cfset variables.ready=true>
	</cffunction>

	<cffunction name="to_xml" access="public" returntype="string" hint="convert DataAction to xml format compatible with client side dataProcessor. Return: DataAction operation report as XML string">
		<cfset var local = structNew()>
		<cfset local.str="<action type='#variables.status#' sid='#variables.id#' tid='#variables.nid#' ">
		<cfloop collection="#variables.attrs#" item="local.k">
			<cfset local.v = variables.attrs[local.k]>
			<cfset local.str = local.str & local.k & "='" & local.v & "' ">
		</cfloop>
		<cfset local.str = local.str & ">#variables.output#</action>">
		<cfreturn local.str>
	</cffunction>

	<cffunction name="__toString" access="public" returntype="string" hint="convert self to string ( for logs ). Return: DataAction operation report as plain string">
		<cfreturn "DataAction Object = [action:#variables.status#, sid:#variables.id#, tid:#variables.nid#]">	
	</cffunction>
</cfcomponent>
	