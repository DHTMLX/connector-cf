<cfcomponent namespace="TreeDataItem" extends="DataItem">
	<cfscript>
		//image of closed folder
		variables.im0="";
		//image of opened folder
		variables.im1="";
		//image of leaf item
		variables.im2="";
		//checked state
		variables.check=0;		
		//checked state
		variables.kids=-1;		
		//collection of custom attributes
		variables.attrs=structNew();
		variables.userdata=structNew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="data" type="any" required="yes" hint="Data object">
		<cfargument name="config" type="any" required="yes" hint="Config Object">
		<cfargument name="index" type="numeric" required="no" default="1" hint="Index of an element">	
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfset variables.im0="">
		<cfset variables.im1="">
		<cfset variables.im2="">
		<cfset variables.check=0>
		<cfset variables.attrs = structNew()>
		<cfset variables.userdata = structNew()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="get_parent_id" access="public" returntype="string" hint="get id of parent record. Return: id of parent record ">
		<cfreturn variables.data[variables.config.relation_id["name"]]>
	</cffunction>

	<cffunction name="get_check_state" access="public" returntype="boolean" hint="get state of items checkbox. Return: state of item's checkbox as int value, false if state was not defined">
		<cfreturn variables.check>
	</cffunction>

	<cffunction name="set_check_state" access="public" returntype="void" hint="set state of item's checkbox">
		<cfargument name="value" type="numeric" required="yes" hint="int value, 1 - checked, 0 - unchecked, -1 - third state">
		<cfset variables.check=ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="has_kids" access="public" returntype="numeric" hint="return count of child items (-1 if there is no info about childs)">
		<cfreturn variables.kids>
	</cffunction>
	<cffunction name="set_kids" access="public" returntype="void" hint="sets count of child items">
		<cfargument name="value" type="numeric" required="yes">
		<cfset variables.kids=ARGUMENTS.value>
	</cffunction>

	<cffunction name="set_attribute" access="public" returntype="void" hint="set custom attribute ">
		<cfargument name="name" type="numeric" required="yes" hint="name of the attribute">
		<cfargument name="value" type="numeric" required="yes" hint="value of the attribute">
		<cfset var local = structNeW()>
		<cfset variables.kids=ARGUMENTS.value>
		<cfswitch expression="#ARGUMENTS.name#">
			<cfcase value="id">
				<cfset set_id(ARGUMENTS.value)>
			</cfcase> 
			<cfcase value="text">
				<cfset local.txt = get_config_data("text")>
				<cfset set_value(local.txt[1]["name"],ARGUMENTS.value)>
			</cfcase> 
			<cfcase value="checked">
				<cfset set_check_state(ARGUMENTS.value)>
			</cfcase> 
			<cfcase value="im0">
				<cfset variables.im0 = ARGUMENTS.value>
			</cfcase> 
			<cfcase value="im1">
				<cfset variables.im1 = ARGUMENTS.value>
			</cfcase> 
			<cfcase value="im2">
				<cfset variables.im2 = ARGUMENTS.value>
			</cfcase> 
			<cfcase value="child">
				<cfset set_kids(ARGUMENTS.value)>
			</cfcase> 
			<cfdefaultcase>
				<cfset variables.attrs[ARGUMENTS.name]=ARGUMENTS.value>
			</cfdefaultcase>
		</cfswitch>
	</cffunction>
	
	<cffunction name="set_userdata" access="public" returntype="void" hint=" set userdata section for the item">
		<cfargument name="name" type="string" required="yes" hint="name of the attribute">
		<cfargument name="value" type="string" required="yes" hint="value of the attribute">
		<cfset variables.userdata[ARGUMENTS.name]=ARGUMENTS.value>
	</cffunction>
	
	<cffunction name="set_image" access="public" returntype="void" hint="assign image for tree's item">
		<cfargument name="img_folder_closed" type="string" required="yes" hint="image for item, which represents folder in closed state">
		<cfargument name="img_folder_open" type="string" required="no" default="" hint="image for item, which represents folder in opened state, optional">
		<cfargument name="img_leaf" type="string" required="no" default="" hint="image for item, which represents leaf item, optional">
		<cfset variables.im0 = ARGUMENTS.img_folder_closed>
		<cfset variables.im1 = iif(Len(ARGUMENTs.img_folder_open),"#DE(ARGUMENTs.img_folder_open)#","#DE(ARGUMENTS.img_folder_closed)#")>
		<cfset variables.im2 = iif(Len(ARGUMENTs.img_leaf),"#DE(ARGUMENTs.img_leaf)#","#DE(ARGUMENTS.img_folder_closed)#")>
	</cffunction>
	
	<cffunction name="to_xml_start" access="public" returntype="string" hint="return self as XML string without ending tag">
		<cfset var local = structNew()>
		<cfif variables.skip>
			<cfreturn "">
		</cfif>
		<cfset local.str1 = "<item id='" & get_id() & "' text='" & xmlFormat(variables.data[variables.config.text[1]["name"]]) & "' ">
		<cfif has_kids()>
			<cfset local.str1 = local.str1 & "child='" & has_kids() & "' ">
		</cfif>
		<cfif Len(variables.im0)>
			<cfset local.str1 = local.str1 & "im0='" & variables.im0 & "' ">
		</cfif>
		<cfif Len(variables.im1)>
			<cfset local.str1 = local.str1 & "im1='" & variables.im1 & "' ">
		</cfif>
		<cfif Len(variables.im2)>
			<cfset local.str1 = local.str1 & "im2='" & variables.im2 & "' ">
		</cfif>
		<cfif variables.check>
			<cfset local.str1 = local.str1 & "checked='" & variables.check & "' ">
		</cfif>
		<cfloop collection="#variables.attrs#" item="local.key">
			<cfset local.str1 = local.str1 & local.key & "='" & xmlFormat(variables.attrs[local.key]) & "' ">
		</cfloop>
		<cfset local.str1 = local.str1 & ">">
		<cfloop collection="#variables.userdata#" item="local.key">
			<cfset local.str1 = local.str1 & "<userdata name='" & local.key & "'><![CDATA[" & variables.userdata[local.key] & "]]></userdata>">
		</cfloop>
		<cfreturn local.str1>
	</cffunction>
	
	<cffunction name="to_xml_end" access="public" returntype="string">
		<cfif variables.skip>
			<cfreturn "">
		</cfif>
		<cfreturn "</item>">
	</cffunction>
</cfcomponent>
