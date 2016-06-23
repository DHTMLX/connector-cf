<cfcomponent namespace="DataViewDataItem" extends="DataItem" hint="DataItem class for DataView component">
	<cfscript>
		variables.id_swap = structNew();
	</cfscript>	
	<cffunction name="init" access="public" returntype="any" hint="Here initilization of all Masters occurs, execution timer initialized">
		<cfargument name="data" type="any" required="yes" hint="Data object">
		<cfargument name="config" type="any" required="yes" hint="Config object">
		<cfargument name="index" type="numeric" required="no" default="1" hint="Index of an element">
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="to_xml" access="public" returntype="string" hint="return self as XML string">
		<cfset var local = structNew()>
		<cfif variables.skip><cfreturn ""></cfif>
		<cfset local.str="<item id='" & get_id() & "' >">
		<cfloop from="1" to="#arrayLen(variables.config.text)#" index="local.i">
			<cfset local.extra = variables.config.text[local.i]["name"]>
			<cfset local.str = local.str & "<" & local.extra & "><![CDATA[" & variables.data[local.extra] & "]]></" & local.extra & ">">
		</cfloop>
		<cfreturn local.str & "</item>">
	</cffunction>
</cfcomponent>			