<cfcomponent namespace="DataConfig" hint="manager of data configuration">
	<cfscript>
		variables.lineBreak = "#chr(13)##chr(10)#";
		variables.tab = "#chr(9)#";
		// name of ID field
		this.id = structNew();			
		// name or relation ID field
		this.relation_id = structNew();	
		// array of text fields
		this.text = ArrayNew(1);
		// array of all known fields , fields which exists only in this collection will not be included in dataprocessor's operations		
		this.data = ArrayNew(1);
	</cfscript>
	
	<!--- ----------------------------------------------------------------------------
		constructor
		init public collectons
		@param proto
			DataConfig object used as prototype for new one, optional
	---------------------------------------------------------------------------- ---> 
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="proto" type="any" required="no">
		<cfif isDefined("ARGUMENTS.proto")>
			<cfset copy(ARGUMENTS.proto)>
		<cfelse>
			<cfset this.text=ArrayNew(1)>
			<cfset this.data=ArrayNew(1)>
			<cfset this.id=structNew()>
			<cfset this.id["name"] = "dhx_auto_id">
			<cfset this.id["db_name"] = "dhx_auto_id">
			<cfset this.relation_id = structNew()>
			<cfset this.relation_id["name"] = "">
			<cfset this.relation_id["db_name"] = "">
		</cfif>
		<cfreturn this>
	</cffunction>	
	
	<cffunction name="copy" access="public" returntype="void">
		<cfargument name="proto" type="any" required="yes">
		<cfset this.id = duplicate(ARGUMENTS.proto.id)>
		<cfset this.relation_id = duplicate(ARGUMENTS.proto.relation_id)>
		<cfset this.text = duplicate(ARGUMENTS.proto.text)>
		<cfset this.data = duplicate(ARGUMENTS.proto.data)>
	</cffunction>
	
	<cffunction name="__toString" access="public" returntype="string">
		<cfset var local = structNew()>
		<cfset local.str="DataConfig Object = [ID:#this.id['db_name']#(ID:#this.id['name']#)#variables.lineBreak#">
		<cfset local.str = local.str & "#variables.tab#Relation ID:#this.relation_id['db_name']#(#this.relation_id['name']#)#variables.lineBreak#">
		<cfif ArrayLen(this.text) eq 0>
			<cfset local.str = local.str & "#variables.tab#Data: [Empy array]#variables.lineBreak#">
		<cfelse>
			<cfset local.str = local.str & "#variables.tab#Data: [">
			<cfloop from="1" to="#ArrayLen(this.text)#" index="local.i">
				<cfif local.i neq ArrayLen(this.text)><cfset local.comma = ",#variables.lineBreak#"><cfelse><cfset local.comma = ""></cfif>
				<cfset local.str = local.str & "#variables.tab##variables.tab##this.text[local.i]['db_name']#(#this.text[local.i]['name']#)#local.comma#">
			</cfloop>
			<cfset local.str = local.str & "#variables.tab#]#variables.lineBreak#">
		</cfif>	
		
		<cfif ArrayLen(this.data) eq 0>
			<cfset local.str = local.str & "#variables.tab#Extra: [Empy array]#variables.lineBreak#">
		<cfelse>
			<cfset local.str = local.str & "#variables.tab#Extra: [">
			<cfloop from="1" to="#ArrayLen(this.data)#" index="local.i">
				<cfif local.i neq ArrayLen(this.data)><cfset local.comma = ",#variables.lineBreak#"><cfelse><cfset local.comma = ""></cfif>
				<cfset local.str = local.str & "#variables.tab##variables.tab##this.data[local.i]['db_name']#(#this.data[local.i]['name']#)#local.comma#">
			</cfloop>
			<cfset local.str = local.str & "#variables.tab#]">
		</cfif>	
		<cfset local.str = local.str & "#variables.tab#]">
		<cfreturn local.str>
	</cffunction>
	
	<cffunction name="minimize" access="public" returntype="void">
		<cfargument name="name" type="string" required="yes">
		<cfset var local = structNew()>
		<cfloop from="1" to="#ArrayLen(this.text)#" index="local.i">
			<cfif this.text[local.i]["name"] eq ARGUMENTS.name>
				<cfset this.text[local.i]["name"]="value">
				<cfset local.tmp = this.text[local.i]>
				<cfset this.data = ArrayNew(1)>
				<cfset this.text = ArrayNew(1)>
				<cfset this.data[1] = local.tmp>
				<cfset this.text[1] = local.tmp> 
				<cfreturn>
			</cfif>		
		</cfloop>
		<cfthrow  errorcode="99" message="Incorrect dataset minimization, master field not found.">	
	</cffunction>
	
	<cffunction name="init_params" access="public" returntype="void">
		<cfargument name="id" type="any" required="yes">
		<cfargument name="fields" type="any" required="yes">
		<cfargument name="extra" type="any" required="yes">
		<cfargument name="relation" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset this.id = parse(ARGUMENTS.id,false)>
		<cfset this.text = parse(ARGUMENTS.fields,true)>
		<cfset this.data = parse(ARGUMENTS.extra,true)>
		<cfloop from="1" to="#ArrayLen(this.text)#" index="local.i">
			<cfset ArrayAPpend(this.data,this.text[local.i])>
		</cfloop>
		<cfif len(ARGUMENTS.relation)>
			<cfset this.relation_id = parse(ARGUMENTS.relation,false)>
		</cfif>
	</cffunction>
	
	<cffunction name="parse" access="private" returntype="any">
		<cfargument name="key" type="string" required="yes">
		<cfargument name="mode" type="boolean" required="yes">
		<cfset var local = structNew()>
		<cfif ARGUMENTS.mode>
			<cfif NOT Len(ARGUMENTS.key)><cfreturn ArrayNew(1)></cfif>
			<cfset ARGUMENTS.key=ListToArray(ARGUMENTS.key,",")>
			<cfloop from="1" to="#ArrayLen(ARGUMENTS.key)#" index="local.i">
				<cfset ARGUMENTS.key[local.i] = parse(ARGUMENTS.key[local.i],false)>
			</cfloop>	
			<cfreturn ARGUMENTS.key>
		</cfif>
		
		<cfset ARGUMENTS.key=ListToArray(ARGUMENTS.key,"(")>
		<cfif NOT ArrayLen(ARGUMENTS.key)>
			<cfset ARGUMENTS.key[1] = "">
		</cfif>
		
		<cfset local.data = structNew()>
		<cfset local.data["db_name"] = trim(ARGUMENTS.key[1])>
		<cfset local.data["name"] = trim(ARGUMENTS.key[1])>
		<cfif ArrayLen(ARGUMENTS.key) gt 1>
			<cfset local.data["name"]=mid(trim(ARGUMENTS.key[2]),1,len(trim(ARGUMENTS.key[2]))-1)>
		</cfif>
		<cfreturn local.data>
	</cffunction>	

	
	<cffunction name="limit_fields" access="public" returntype="any">
		<cfargument name="data" type="struct" required="yes">
		<cfset var local = structNew()>
		<cfset this.restore_fields()>
		<cfset this.full_field_list = this.text>
		<cfset this.text = ArrayNew(1)>
			
		<cfloop from="1" to="#ArrayLen(this.full_field_list)#"	 index="local.i">
			<cfif structKeyExists(ARGUMENTS.data,this.full_field_list[local.i]["name"])>
				<cfset ArrayAppend(this.text,this.full_field_list[local.i])>
			</cfif>
		</cfloop>
	</cffunction>
		
	<cffunction name="restore_fields" access="public" returntype="void">
		<cfif isDefined("this.full_field_list")>
			<cfset this.text = this.full_field_list>
		</cfif>	
	</cffunction>
	
	<!--- ----------------------------------------------------------------------------
		return 
			list of data fields ( ready to be used in SQL query )
	---------------------------------------------------------------------------- ---> 
	<cffunction name="db_names_list" access="public" returntype="string" hint="returns list of data fields (db_names)">
		<cfargument name="db" required="yes" type="any">
		<cfset var local = structNew()>
		<cfset local.out= ArrayNew(1)>
		<cfif len(this.id["db_name"])>
			<cfset ArrayAppend(local.out,ARGUMENTS.db.escape_name(this.id["db_name"]))>
		</cfif>	
		<cfif len(this.relation_id["db_name"])>
			<cfset ArrayAppend(local.out,ARGUMENTS.db.escape_name(this.relation_id["db_name"]))>
		</cfif>
		<cfloop from="1" to="#ArrayLen(this.data)#" index="local.i">
			<cfif this.data[local.i]["db_name"] neq this.data[local.i]["name"]>
				<cfset ArrayAppend(local.out,ARGUMENTS.db.escape_name(this.data[local.i]["db_name"]) & " as " & ARGUMENTS.db.escape_name(this.data[local.i]["name"]))>
			<cfelse>
				<cfset ArrayAppend(local.out,ARGUMENTS.db.escape_name(this.data[local.i]["db_name"]))>
			</cfif>	
		</cfloop>
		<cfreturn ArraytoList(local.out,",")>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------
		add field to dataset config ($text collection)
		added field will be used in all auto-generated queries
		@param name 
			name of field
		@param aliase
			aliase of field, optional
	---------------------------------------------------------------------------- ---> 
	<cffunction name="add_field" access="public" returntype="void">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="aliase" type="any" required="no" default="">
		
		<cfset var local=structNew()>
		<cfif NOT len(ARGUMENTS.aliase)>
			<cfset ARGUMENTS.aliase=ARGUMENTS.name>
		</cfif>
		
		<!---adding to list of data-active fields --->
		<cfif this.id["db_name"] eq ARGUMENTS.name OR this.relation_id["db_name"] eq ARGUMENTS.name>
			<cfinvoke component="EventMaster" method="do_log">
				<cfinvokeargument name="message" value="Field name already used as ID, be sure that it is really necessary.">
			</cfinvoke>
		</cfif>
		<cfif is_field(ARGUMENTS.name,this.text) neq -1>
			<cfthrow errorcode="99" message="Data field already registered: #ARGUMENTS.name#">
		</cfif>
		
		<cfset local.st = structNew()>
		<cfset local.st["db_name"] = ARGUMENTS.name>
		<cfset local.st["name"] = ARGUMENTS.aliase>
		<cfset ArrayAppend(this.text,local.st)>
		
		<!--- adding to list of all fields as well --->
		<cfif is_field(ARGUMENTS.name,this.data) eq -1>
			<cfset local.st = structNew()>
			<cfset local.st["db_name"] = ARGUMENTS.name>
			<cfset local.st["name"] = ARGUMENTS.aliase>
			<Cfset ArrayAppend(this.data,local.st)>
		</cfif>	
	</cffunction>
	<!--- ----------------------------------------------------------------------------
		remove field from dataset config ($text collection)

		removed field will be excluded from all auto-generated queries
		@param name 
			name of field, or aliase of field
	---------------------------------------------------------------------------- ---> 
	<cffunction name="remove_field" access="public" returntype="void">
		<cfargument name="name" type="string" required="yes">
		<cfset var local = structnew()>
		<cfset local.ind = is_field(ARGUMENTS.name)>
		<cfif local.ind eq -1>
			 <cfthrow errorcode="99" message="There was no such data field registered as: #ARGUMENTS.name#">
		</cfif>	 
		<cfset ArrayDeleteAt(this.data,local.ind)>
		<cfset ArrayDeleteAt(this.text,local.ind)>
		<!---
			we not deleting field from $data collection, so it will not be included in data operation, but its data still available
		--->
	</cffunction>
	<!--- ----------------------------------------------------------------------------
		check if field is a part of dataset
		@param name 
			name of field
		@param collecton
			collection, against which check will be done, $text collection by default
		@return 
			returns true if field already a part of dataset, otherwise returns true
	---------------------------------------------------------------------------- ---> 
	<cffunction name="is_field" access="private" returntype="numeric">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="collection" type="any" required="no">
		<cfset var local = structNew()>
		<cfif not isDefined("ARGUMENTS.collection")>
			<cfset ARGUMENTS.collection=this.text>
		</cfif>	
		<cfloop from="1" to="#ArrayLen(ARGUMENTs.collection)#" index="local.i">
			<cfif ARGUMENTS.collection[local.i]["name"] eq ARGUMENTS.name OR ARGUMENTS.collection[local.i]["db_name"] eq ARGUMENTS.name>
				<cfreturn local.i>
			</cfif>
		</cfloop>
		<cfreturn -1>
	</cffunction>
</cfcomponent>
