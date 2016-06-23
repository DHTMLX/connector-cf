<cfcomponent namespace="ComboDataItem" extends="DataItem" hint="DataItem class for Combo component">
	<cfscript>
		//flag of selected option
		variables.selected = false;
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="data" type="any" required="yes" hint="Data object">
		<cfargument name="config" type="any" required="yes" hint="Config object">
		<cfargument name="index" type="numeric" required="no" default="1" hint="Index of an element">
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfset variables.selected=false>
		<cfreturn this>
	</cffunction>

	<cffunction name="select" access="public" returntype="void" hint="mark option as selected">
		<cfset variables.selected=true>
	</cffunction>

	<cffunction name="to_xml_start" access="public" returntype="string" hint="return self as XML string">
		<cfif variables.skip>
			<cfreturn "">
		</cfif> 
		<cfreturn "<option " & IIF(variables.selected,DE("selected='true'"),DE("")) & "value='" & get_id() & "'><![CDATA[" & variables.data[variables.config.text[1]["name"]] & "]]>">
	</cffunction>
	<cffunction name="to_xml_end" access="public" returntype="string">
		<cfif variables.skip>
			<cfreturn "">
		</cfif> 
		<cfreturn "</option>">
	</cffunction>
</cfcomponent>
	