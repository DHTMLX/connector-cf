<cfcomponent namespace="TreeGridDataItem" extends="GridDataItem" hint="DataItem class for TreeGrid component">
	<cfscript>
		//checked state
		variables.kids=-1;
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="data" type="any" required="yes" hint="Data object">
		<cfargument name="config" type="any" required="yes" hint="Config object">
		<cfargument name="index" type="numeric" required="no" default="1" hint="Index of an element">
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfset variables.im0="">
		<cfreturn this>
	</cffunction>

	<cffunction name="get_parent_id" access="public" returntype="any" hint="return id of parent record. Return: id of parent record">
		<cfreturn variables.data[variables.config.relation_id["name"]]>
	</cffunction>

	<cffunction name="set_image" access="public" returntype="any" hint="assign image to treegrid's item. longer description">
		<cfargument name="img" type="string" required="yes" hint="relative path to the image">
		<cfset set_cell_attribute(variables.config.text[1]["name"],"image",ARGUMENTS.img)>
	</cffunction>
	<cffunction name="has_kids" access="public" returntype="numeric" hint="return count of child items (-1 if there is no info about childs)">
		<cfreturn variables.kids>
	</cffunction>
	<cffunction name="set_kids" access="public" returntype="void" hint="sets count of child items">
		<cfargument name="value" type="numeric" required="yes">
		<cfset variables.kids=ARGUMENTS.value>
		<cfif ARGUMENTS.value>
			<cfset set_row_attribute("xmlkids",ARGUMENTS.value)>
		</cfif>	
	</cffunction>
</cfcomponent>
