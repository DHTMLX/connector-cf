<cfcomponent namespace="GridDataItem" extends="DataItem" hint="DataItem class for Grid component">
	<cfscript>
		//hash of row attributes
		variables.row_attrs = structNew();
		//hash of cell attributes
		variables.cell_attrs = structNew();
		//userdata
		variables.userdata = structNew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="data" type="any" required="yes" hint="Data object">
		<cfargument name="config" type="any" required="yes" hint="config object">
		<cfargument name="index" type="numeric" required="no" default="1" hint="Index of an element">
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfset variables.row_attrs=structNew()>
		<cfset variables.cell_attrs=structNew()>
		<cfset variables.userdata = structNew()>
		<cfreturn this>
	</cffunction>

	<cffunction name="set_row_color" access="public" returntype="void" hint="Set color of row">
		<cfargument name="color" type="string" required="yes" hint="color of row">
		<cfset variables.row_attrs["bgColor"]=ARGUMENTS.color>
	</cffunction>

	<cffunction name="set_row_style" access="public" returntype="void" hint="Set style of row">
		<cfargument name="style" type="string" required="yes" hint="style of row">
		<cfset variables.row_attrs["style"]=ARGUMENTS.style>
	</cffunction>

	<cffunction name="set_cell_style" access="public" returntype="void" hint="assign custom style to the column">
		<cfargument name="name" type="string" required="yes" hint="name of column">
		<cfargument name="value" type="string" required="yes" hint="css style string">
		<cfset set_cell_attribute(ARGUMENTS.name,"style",ARGUMENTS.value)>
	</cffunction>
	<cffunction name="set_cell_class" access="public" returntype="void" hint="assign custom class to specific column">
		<cfargument name="name" type="string" required="yes" hint="name of column">
		<cfargument name="value" type="string" required="yes" hint="css class name">
		<cfset set_cell_attribute(ARGUMENTS.name,"class",ARGUMENTS.value)>
	</cffunction>
	
	<cffunction name="set_cell_attribute" access="public" returntype="void" hint="set custom cell attribute">
		<cfargument name="name" type="string" required="yes" hint="name of column">
		<cfargument name="attr" type="string" required="yes" hint="name of attribute">
		<cfargument name="value" type="string" required="yes" hint="value of attribute">
		<cfif not structKeyExists(variables.cell_attrs,ARGUMENTS.name)>
			<cfset variables.cell_attrs[ARGUMENTS.name]=structNew()>
		</cfif> 
		<cfset variables.cell_attrs[ARGUMENTS.name][ARGUMENTS.attr]=ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="set_userdata" access="public" returntype="void" hint="set userdata section for the item">
		<cfargument name="name" type="string" required="yes" hint="name of userdata">
		<cfargument name="value" type="string" required="yes" hint="value of userdata">
		<cfset variables.userdata[ARGUMENTS.name]=ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="set_row_attribute" access="public" returntype="void" hint="set custom row attribute">
		<cfargument name="attr" type="string" required="yes" hint="name of attribute">
		<cfargument name="value" type="string" required="yes" hint="value of attribute">
		<cfset variables.row_attrs[ARGUMENTS.attr]=ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="fixXMLProblems" access="private" returntype="string">
		<cfargument name="str" type="string" required="yes" hint="">
		<cfset var local = structNew()>
		<cfset local.str = rereplaceNoCase(ARGUMENTS.str,"[#chr(18)##chr(19)#]+","","all")>
		<cfreturn local.str>
	</cffunction>
	
	<cffunction name="to_xml_start" access="public" returntype="string" hint="return self as XML string without ending tag">
		<cfset var local = structNew()>
		<cfif variables.skip>
			<cfreturn "">
		</cfif>
		<cfset local.str = "<row id='" & get_id() & "'">
		<cfloop collection="#variables.row_attrs#" item="local.k">
			<cfset local.v = variables.row_attrs[local.k]>
			<cfset local.str = local.str & " " & local.k &  "='" & local.v & "'">
		</cfloop>
		<cfset local.str = local.str & ">">
		<cfloop from="1" to="#ArrayLen(variables.config.text)#" index="local.i">
			<cfset local.str = local.str & "<cell">
			<cfset local.name=variables.config.text[local.i]["name"]>
			<cfif structKeyExists(variables.cell_attrs,local.name)>
				<cfset local.cattrs=variables.cell_attrs[local.name]>
				<cfloop collection="#local.cattrs#" item="local.k">
					<cfset local.v = local.cattrs[local.k]>
					<cfset local.str = local.str & " " & local.k & "='" & xmlFormat(local.v) & "'">
				</cfloop>
			</cfif>
			<cfif structKeyExists(variables.data,local.name)>
				<cfset local.str = local.str & "><![CDATA[" & fixXMLProblems(variables.data[local.name]) & "]]></cell>">
			<cfelse>	
				<cfset local.str = local.str & " />">
			</cfif>	
		</cfloop>
		<cfloop collection="#variables.userdata#" item="local.k">
			<cfset local.str = local.str & "<userdata name='" & local.k & "'><![CDATA[" & fixXMLProblems(variables.userdata[local.k]) & "]]></userdata>">
		</cfloop>	
		<cfreturn local.str>
	</cffunction>

	<cffunction name="to_xml_end" access="public" returntype="string" hint="return ending tag for self as XML string ">
		<cfif variables.skip>
			<cfreturn "">
		</cfif>
		<cfreturn "</row>">
	</cffunction>
</cfcomponent>
