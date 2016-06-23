<cfcomponent namespace="GridConfiguration">
	<!--- attaching header functionality --->
	<cfset variables.headerDelimiter = ','>
	<cfset variables.headerNames = false>
	<cfset variables.headerAttaches = arrayNew(1)>
	<cfset variables.footerAttaches = arrayNew(1)>
	<cfset variables.headerWidthsUnits = 'px'>
	
	<cfset variables.headerIds = "">
    <cfset variables.headerWidths = "">
    <cfset variables.headerTypes = "">
	<cfset variables.headerAlign  = "">
	<cfset variables.headerVAlign = "">
	<cfset variables.headerSorts  = "">
	<cfset variables.headerColors = "">
	<cfset variables.headerHidden = "">
	
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="headers" type="any" required="no" default="false">
		<cfif isBoolean(ARGUMENTS.headers)>
			<cfset variables.headerNames = ARGUMENTS.headers>
		<cfelse>
			<cfset setHeader(ARGUMENTS.headers)>
		</cfif>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="parse_param_array" access="private" returntype="array" hint=" brief convert list of parameters to an array">
		<cfargument name="param" type="any" required="yes" hint="list of values or array of values">
		<cfargument name="check" type="any" required="no" default="">
		<cfargument name="default" type="string" required="no" default="">
		<cfset var local = structNew()>
		<cfif not isArray(ARGUMENTS.param)>
			<cfset ARGUMENTS.param = ListToArray(ARGUMENTS.param,variables.headerDelimiter)>
		</cfif>		
		<cfif isStruct(ARGUMENTS.check)>
			<cfloop from="1" to="#ArrayLen(ARGUMENTS.param)#" index="local.i">
				<cfif not structKeyExists(ARGUMENTS.check,ARGUMENTS.param[local.i])>
					<cfset ARGUMENTS.param[local.i] = ARGUMENTS.default>
				</cfif>	
			</cfloop>
		</cfif>
		<cfreturn ARGUMENTS.param>
	</cffunction>
	
	<cffunction name="setHeaderDelimiter" access="public" returntype="void" hint="sets delimiter for string arguments in attach header functions (default is ,)">
		<cfargument name="headerDelimiter" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset variables.headerDelimiter = ARGUMENTS.headerDelimiter>
	</cffunction>
	
	
	<cffunction name="setHeader" access="public" returntype="void" hint="sets header">
		<cfargument name="names" type="any" required="yes" hint="array of names or string of names, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfif isObject(ARGUMENTS.names)>
			<cfset local.out = ArrayNew(1)>
			<cfloop from="1" to="#ArrayLen(ARGUMENTS.names.text)#" index="local.i">
				<cfset ArrayAppend(local.out,ARGUMENTS.names.text[local.i]["name"])>
			</cfloop>
			<cfset ARGUMENTS.names = local.out>
		</cfif>	
		<cfset variables.headerNames = parse_param_array(ARGUMENTS.names)>
	</cffunction>
	
	
	<cffunction name="setInitWidths" access="public" returntype="void" hint="sets init columns width in pixels">
		<cfargument name="wp" type="any" required="yes" hint="array of widths or string of widths, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset variables.headerWidths = parse_param_array(ARGUMENTS.wp)>
		<cfset variables.headerWidthsUnits = 'px'>
	</cffunction>

	<cffunction name="setInitWidthsP" access="public" returntype="void" hint="sets init columns width in persents">
		<cfargument name="wp" type="any" required="yes" hint="array of widths or string of widths, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset setInitWidths(ARGUMENTS.wp)>
		<cfset variables.headerWidthsUnits = '%'>
	</cffunction>


	<cffunction name="setColAlign" access="public" returntype="void" hint="sets columns align">
		<cfargument name="alStr" type="any" required="yes" hint="array of aligns or string of aligns, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset local.s = structNew()>
		<cfset local.s["right"] = 1>
		<cfset local.s["left"] = 1>
		<cfset local.s["center"] = 1>
		<cfset local.s["justify"] = 1>
		<cfset variables.headerAlign = parse_param_array(ARGUMENTS.alStr,local.s,"left")>
	</cffunction>
	
	<cffunction name="setColVAlign" access="public" returntype="void" hint="sets columns vertical align">
		<cfargument name="alStr" type="any" required="yes" hint="array of vertical aligns or string of vertical aligns, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset local.s = structNew()>
		<cfset local.s["baseline"] = 1>
		<cfset local.s["sub"] = 1>
		<cfset local.s["super"] = 1>
		<cfset local.s["top"] = 1>
		<cfset local.s["text-top"] = 1>
		<cfset local.s["middle"] = 1>
		<cfset local.s["bottom"] = 1>
		<cfset local.s["text-bottom"] = 1>
		<cfset variables.headerVAlign = parse_param_array(ARGUMENTS.alStr,local.s,"top")>
	</cffunction>
	
	<cffunction name="setColTypes" access="public" returntype="void" hint="sets column types">
		<cfargument name="typeStr" type="any" required="yes" hint="array of types or string of types, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset variables.headerTypes = parse_param_array(ARGUMENTS.typeStr)>
	</cffunction>
	
	<cffunction name="setColSorting" access="public" returntype="void" hint="sets column sorting">
		<cfargument name="sortStr" type="any" required="yes" hint="array if sortings or string of sortings, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset variables.headerSorts = parse_param_array(ARGUMENTS.sortStr)>
	</cffunction>
	
	<cffunction name="setColColor" access="public" returntype="void" hint="sets columns colors">
		<cfargument name="colorStr" type="any" required="yes" hint="array of colors or string of colors, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset variables.headerColors = parse_param_array(ARGUMENTS.colorStr)>
	</cffunction>
	
	<cffunction name="setColHidden" access="public" returntype="void" hint="sets hidden columns">
		<cfargument name="hidStr" type="any" required="yes" hint="array of bool values or string of bool values, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset variables.headerHidden = parse_param_array(ARGUMENTS.hidStr)>
	</cffunction>
	
	<cffunction name="setColIds" access="public" returntype="void" hint="sets hidden id">
		<cfargument name="idsStr" type="any" required="yes" hint="array of ids or string of ids, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset variables.headerIds = parse_param_array(ARGUMENTS.idsStr)>
	</cffunction>
	
	<cffunction name="attachHeader" access="public" returntype="void" hint="attaches header">
		<cfargument name="values" type="any" required="yes" hint="array of header names or string of header names, delimited by headerDelimiter (default is ,)">
		<cfargument name="styles" type="any" required="no" default="" hint="array of header styles or string of header styles, delimited by headerDelimiter (default is ,)">
		<cfargument name="footer" type="boolean" required="no" default="false" hint="">
		<cfset var local = structNew()>
		<cfset local.header = structNew()>
		<cfset local.header['values'] = parse_param_array(ARGUMENTS.values)>
		<cfif not isSimpleValue(ARGUMENTS.styles) OR ARGUMENTS.styles neq "">
			<cfset local.header['styles'] = parse_param_array(ARGUMENTS.styles)>
		<cfelse>
			<cfset local.header['styles'] = "">
		</cfif>
		<cfif ARGUMENTS.footer>
			<cfset arrayAppend(variables.footerAttaches, local.header)>
		<cfelse>
			<cfset arrayAppend(variables.headerAttaches, local.header)>
		</cfif>	
	</cffunction>

	<cffunction name="attachFooter" access="public" returntype="void" hint="attaches footer">
		<cfargument name="values" type="any" required="yes" hint="array of footer names or string of footer names, delimited by headerDelimiter (default is ,)">
		<cfargument name="styles" type="any" required="no" default="" hint="array of footer styles or string of footer styles, delimited by headerDelimiter (default is ,)">
		<cfset var local = structNew()>
		<cfset attachHeader(ARGUMENTS.values, ARGUMENTS.styles, true)>
	</cffunction>
	
	
	<cffunction name="auto_fill" access="private" returntype="void">
		<cfargument name="mode" type="boolean" required="yes">
		<cfset var local = structNew()>
		<cfset local.headerWidths = ArrayNew(1)>
		<cfset local.headerTypes = ArrayNew(1)>
		<cfset local.headerSorts = ArrayNew(1)>
		<cfset local.headerAttaches = ArrayNew(1)>
		
		<cfloop from="1" to="#ArrayLen(variables.headerNames)#" index="local.i">
			<cfset ArrayAppend(local.headerWidths,100)>
			<cfset ArrayAppend(local.headerTypes,"ro")>
			<cfset ArrayAppend(local.headerSorts,"connector")>
			<cfset ArrayAppend(local.headerAttaches,"##connector_text_filter")>
		</cfloop>
		<cfif not isArray(variables.headerWidths)>
			<cfset setInitWidths(local.headerWidths)>
		</cfif>	
		<cfif not isArray(variables.headerTypes)>
			<cfset setColTypes(local.headerTypes)>
		</cfif>	
		<cfif ARGUMENTS.mode>
			<cfif not isArray(variables.headerSorts)>
				<cfset setColSorting(local.headerSorts)>
			</cfif>	
			<cfset attachHeader(local.headerAttaches)>
		</cfif>
	</cffunction>
	
	
	<cffunction name="attachHeaderToXML" access="public" returntype="void" hint="adds header configuration in output XML">
		<cfargument name="conn" type="any" required="yes">
		<cfargument name="out" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.config = ARGUMENTS.conn.get_config()>
		<cfif not ARGUMENTS.conn.is_first_call()>
			<!--- render head only for first call--->
			<cfreturn>
		</cfif>

		<cfif isBoolean(variables.headerNames) AND variables.headerNames eq "true">
			<cfset local.full_header = true>
		<cfelse>		
			<cfset local.full_header = false>
		</cfif>
		<cfif isBoolean(variables.headerNames)>
			<!--- auto-config --->
			<cfset setHeader(local.config)>
		</cfif>
		<cfset auto_fill(local.full_header)>
		<cfset local.str = '<head>'>
		<cfif isArray(variables.headerNames)>
			<cfloop from="1" to="#arrayLen(variables.headerNames)#" index="local.i">
				<cfset local.str = local.str &  '<column'>
				<cfif isArray(variables.headerTypes) AND local.i lte ArrayLen(variables.headerTypes)>
					<cfset local.str = local.str & ' type="' &  variables.headerTypes[local.i] & '"'>
				</cfif>	
				<cfif isArray(variables.headerWidths) AND local.i lte ArrayLen(variables.headerWidths)>
					<cfset local.str = local.str & ' width="' & variables.headerWidths[local.i] & '"'>
				</cfif>		
				<cfif isArray(variables.headerIds) AND local.i lte ArrayLen(variables.headerIds)>
					<cfset local.str = local.str & ' id="' & variables.headerIds[local.i] & '"'>
				</cfif>		
				<cfif isArray(variables.headerAlign) AND local.i lte ArrayLen(variables.headerAlign)>	
					<cfset local.str = local.str & ' align="' & variables.headerAlign[local.i] & '"'>
				</cfif>		
				<cfif isArray(variables.headerVAlign) AND local.i lte ArrayLen(variables.headerVAlign)>	
					<cfset local.str = local.str & ' valign="' & variables.headerVAlign[local.i] & '"'>
				</cfif>		
				<cfif isArray(variables.headerSorts) AND local.i lte ArrayLen(variables.headerSorts)>	
					<cfset local.str = local.str & ' sort="' & variables.headerSorts[local.i] & '"'>
				</cfif>		
				<cfif isArray(variables.headerColors) AND local.i lte ArrayLen(variables.headerColors)>	
					<cfset local.str = local.str & ' color="' & variables.headerColors[local.i] & '"'>
				</cfif>	
				<cfif isArray(variables.headerHidden) AND local.i lte ArrayLen(variables.headerHidden)>	
					<cfset local.str = local.str & ' hidden="' & variables.headerHidden[local.i] & '"'>
				</cfif>	
				<cfset local.str = local.str & '>' & variables.headerNames[local.i] & '</column>'>
			</cfloop>
		</cfif>	
		<cfset local.str = local.str & '<settings><colwidth>' & variables.headerWidthsUnits & '</colwidth></settings>'>
		<cfif ArrayLen(variables.headerAttaches) OR ArrayLen(variables.footerAttaches)>
			<cfset local.str = local.str & '<afterInit>'>
		</cfif>
		<cfloop from="1" to="#ArrayLen(variables.headerAttaches)#" index="local.i">
			<cfset local.str = local.str & '<call command="attachHeader">'>
			<cfset local.str = local.str & '<param>' & ArrayToList(variables.headerAttaches[local.i]['values']) & '</param>'>
			<cfif isArray(variables.headerAttaches[local.i]['styles'])>
				<cfset local.str = local.str & '<param>' & ArrayToList(variables.headerAttaches[local.i]['styles']) & '</param>'>
			</cfif>
			<cfset local.str = local.str & '</call>'>
		</cfloop>
		<cfloop from="1" to="#ArrayLen(variables.footerAttaches)#" index="local.i">
			<cfset local.str = local.str & '<call command="attachFooter">'>
			<cfset local.str = local.str & '<param>' & ArrayToList(variables.footerAttaches[local.i]['values']) & '</param>'>
			<cfif isArray(variables.footerAttaches[local.i]['styles'])>
				<cfset local.str = local.str & '<param>' & ArrayToList(variables.footerAttaches[local.i]['styles']) & '</param>'>
			</cfif>
			<cfset local.str = local.str & '</call>'>
		</cfloop>
		<cfif ArrayLen(variables.headerAttaches) OR ArrayLen(variables.footerAttaches)>
			<cfset local.str = local.str & '</afterInit>'>
		</cfif>
		<cfset local.str = local.str & '</head>'>
		<cfset ARGUMENTS.out.add(local.str)>
	</cffunction>
</cfcomponent>
