<cfcomponent namespace="FileSystemTypes">
	<cfscript>
		if (not isDefined("request.FileSystemTypes_static")){
			request.FileSystemTypes_static = structNew();
			request.FileSystemTypes_static.instance = "";
		};	
		variables.extentions = ArrayNew(1);
		variables.extentions_not = ArrayNew(1);
		variables.all = true;
		variables.patterns = ArrayNew(1);
		// predefined types
		variables.types = structNew();
		variables.types['image'] = ListToarray("jpg,jpeg,gif,png,tiff,bmp,psd,dir");
		variables.types['document'] = ListToarray("txt,doc,docx,xls,xlsx,rtf,dir");
		variables.types['web'] = ListToarray("php,cfm,cfml,jsp,asp,html,htm,js,css,dir");
		variables.types['audio'] = ListToarray("mp3,wav,ogg,dir");
		variables.types['video'] = ListToarray("avi,mpg,mpeg,mp4,dir");
		variables.types['only_dir'] = ListToarray("dir");
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any">
		<cfreturn this>
	</cffunction>
	<cffunction name="getInstance" access="public" returntype="any">
		<cfset var local = structNew()>
		<cfif not isObject(request.FileSystemTypes_static.instance)>
			<cfset request.FileSystemTypes_static.instance = CreateObject("component","FileSystemTypes").init()>
		</cfif>
		<cfreturn request.FileSystemTypes_static.instance>
	</cffunction>
	
	<cffunction name="setExtentions" access="public" returntype="void" hint="sets array of extentions">
		<cfargument name="ext" type="array" required="yes">
		<cfset var local = structNew()>
		<cfset variables.all = false>
		<cfset variables.extentions = ARGUMENTS.ext>
	</cffunction>
	
	<cffunction name="addExtention" access="public" returntype="void" hint="adds one extention in array">
		<cfargument name="ext" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset variables.all = false>
		<cfset ArrayAppend(variables.extentions,ARGUMENTS.ext)>
	</cffunction>

	<cffunction name="addExtentionNot" access="public" returntype="void" hint="adds one extention which will not ouputed in array">
		<cfargument name="ext" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset ArrayAppend(variables.extentions_not,ARGUMENTS.ext)>
	</cffunction>

	<cffunction name="getExtentions" access="public" returntype="array" hint="returns array of extentions">
		<cfset var local = structNew()>
		<cfreturn variables.extentions>
	</cffunction>
	
	<cffunction name="addPattern" access="public" returntype="void" hint="adds regexp pattern">
		<cfargument name="pattern" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset variables.all = false>
		<cfset ArrayAppend(variables.patterns,ARGUMENTS.pattern)>
	</cffunction>
	
	<cffunction name="clearExtentions" access="public" returntype="void" hint="clear extentions array">
		<cfset var local = structNew()>
		<cfset variables.all = true>
		<cfset variables.extentions = ArrayNew(1)>
	</cffunction>

	<cffunction name="clearPatterns" access="public" returntype="void" hint="clear regexp patterns array">
		<cfset var local = structNew()>
		<cfset variables.all = true>
		<cfset variables.patterns = ArrayNew(1)>
	</cffunction>

	<cffunction name="clearAll" access="public" returntype="void" hint="clear all filters">
		<cfset var local = structNew()>
		<cfset clearExtentions()>
		<cfset clearPatterns()>
	</cffunction>

	<cffunction name="setType" access="public" returntype="boolean" hint="sets predefined type">
		<cfargument name="type" type="string" required="yes">
		<cfargument name="clear" type="boolean" required="no" default="false">
		<cfset var local = structNew()>
		<cfset variables.all = false>
		<cfif ARGUMENTS.type eq 'all'>
			<cfset variables.all = true>
			<cfreturn true>
		</cfif>
		<cfif structKeyExists(variables.types,ARGUMENTS.type)>
			<cfif ARGUMENTS.clear>
				<cfset clearExtentions()>
			</cfif>
			<cfloop from="1" to="#ArrayLen(variables.types[ARGUMENTS.type])#" index="local.i">
				<cfset ArrayAppend(variables.extentions,variables.types[ARGUMENTS.type][local.i])>
			</cfloop>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	<cffunction name="checkFile" access="public" returntype="boolean" hint="check file under setted filter">
		<cfargument name="filename" type="string" required="yes">
		<cfargument name="fileNameExt" type="struct" required="yes">
		<cfset var local = structNew()>

		<cfif ArrayFind(variables.extentions_not,ARGUMENTS.fileNameExt['ext'])>
			<cfreturn false>
		</cfif>
		
		<cfif variables.all>
			<cfreturn true>
		</cfif>

		<cfif ArrayLen(variables.extentions) AND not ArrayFind(variables.extentions,ARGUMENTS.fileNameExt['ext'])>
			<cfreturn false>
		</cfif>
		
		<cfloop from="1" to="#ArrayLen(variables.patterns)#" index="local.i">
			<cfif not ReFindNoCase(variables.patterns[local.i],ARGUMENTS.fileName)>
				<cfreturn false>
			</cfif>
		</cfloop>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="ArrayFind" access="private" returntype="numeric">
		<cfargument name="ar" type="array" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfset var local = structNew()>
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.ar)#" index="local.i">
			<cfif ARGUMENTS.ar[local.i] eq ARGUMENTS.value>
				<cfreturn local.i>
			</cfif>
		</cfloop>
		<cfreturn 0>
	</cffunction>
</cfcomponent>
