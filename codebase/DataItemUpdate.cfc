<!---
	DataItemUpdate class for realization Optimistic concurrency control
	Wrapper for DataItem object
	It's used during outputing updates instead of DataItem object
	Create wrapper for every data item with update information.
--->
<cfcomponent namespace="DataItemUpdate" extends="DataItem">
	<cfset variables.child = "">
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="data" type="any" required="yes" hint="Data Object">
		<cfargument name="config" type="any" required="yes" hint="Config Object">
		<cfargument name="index" type="numeric" required="yes" hint="index of element">
		<cfargument name="type" type="string" required="yes">
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfset variables.child = CreateObject("component","#ARGUMENTS.type#").init(ARGUMENTS.data, ARGUMENTS.config, ARGUMENTS.index)>
		<cfreturn this>
	</cffunction>


	<cffunction name="get_parent_id" access="public" returntype="string" hint="returns parent_id (for Tree and TreeGrid components)">
		<cfif isDefined("variables.child.get_parent_id") AND IsCustomFunction(evaluate('variables.child.get_parent_id'))>
			<cfreturn variables.child.get_parent_id()>
		<cfelse>	
			<cfreturn "">	
		</cfif>
	</cffunction>

	<cffunction name="to_xml" access="public" returntype="string" hint="return self as XML string">
		<cfset var local = structNew()>
		<cfset local.str= "<update ">
		<cfset local.str= local.str  &  'status="' & variables.data['type'] & '" '>
		<cfset local.str= local.str  & 'id="' & variables.data['dataId'] & '" '>
		<cfset local.str= local.str  & 'parent="' & get_parent_id() & '"'>
		<cfset local.str= local.str  & '>'>
		<cfset local.str= local.str  & variables.child.to_xml()>
		<cfset local.str= local.str  & '</update>'>
		<cfreturn local.str>
	</cffunction>
	
	<cffunction name="to_xml_start" access="public" returntype="string" hint="return end tag for self as XML string ">
		<cfset var local = structNew()>
		
		<cfset local.str="<update ">
		<cfset local.str = local.str & 'status="' & variables.data['type'] & '" '>
		<cfset local.str = local.str & 'id="' & variables.data['dataId'] & '" '>
		<cfset local.str = local.str & 'parent="' & get_parent_id() & '"'>
		<cfset local.str = local.str & '>'>
		<cfset local.str = local.str & variables.child.to_xml_start()>
		<cfreturn local.str>
	</cffunction>

	<cffunction name="to_xml_end" access="public" returntype="string" hint="return self as XML string">
		<cfset var local = structNew()>
		<cfset local.str = variables.child.to_xml_end()>
		<cfset local.str = local.str & '</update>'>
		<cfreturn local.str>
	</cffunction>
	
	
	<cffunction name="has_kids" access="public" returntype="boolean" hint="returns false for outputing only current item without child items">
		<cfreturn false>
	</cffunction>
	
	<cffunction name="set_kids" access="public" returntype="void" hint="sets count of child items">
		<cfargument name="value" type="any" required="yes" hint="count of child items">
		<cfif isDefined("variables.child.set_kids") AND IsCustomFunction(evaluate('variables.child.set_kids'))>
			<cfset variables.child.set_kids(ARGUMENTS.value)>
		</cfif>
	</cffunction>
	
	<cffunction name="set_attribute" access="public" returntype="void" hint="sets attribute for item">
		<cfargument name="name" type="any" required="yes">
		<cfargument name="value" type="any" required="yes">
		<cfif isDefined("variables.child.set_attribute") AND IsCustomFunction(evaluate('variables.child.set_attribute'))>
			<cfinvoke component="LogMaster" method="do_log">
				<cfinvokeargument name="message" value="Setting attribute: name = #ARGUMENTS.name#; value = #ARGUMENTS.value#">
			</cfinvoke>	
			<cfset variables.child.set_attribute(ARGUMENTS.name,ARGUMENTS.value)>
		<cfelse>
			<cfinvoke component="LogMaster" method="do_log">
				<cfinvokeargument name="message" value="Method set_attribute doesn't exists">
			</cfinvoke>	
		</cfif>
	</cffunction>
</cfcomponent>
