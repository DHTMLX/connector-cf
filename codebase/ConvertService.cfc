<cfcomponent namespace="ConvertService">
	<cfset variables._url = "">
	<cfset variables.type = "">
	<cfset variables.name = "">
	<cfset variables.inline = false>
	
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="_url" type="string" required="yes">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="inline" type="boolean" required="no" default="false">
		
		<cfset var local = structNew()>
		<cfset variables._url = ARGUMENTS._url>
		<cfset variables.name = ARGUMENTS.name>
		<cfset variables.inline = ARGUMENTS.inline>
		<cfset pdf()>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = this>
		<cfset local.ar[2] = "handle">
		<cfinvoke component="EventMaster" method="attach_static">
			<cfinvokeargument name="name" value="connectorInit">
			<cfinvokeargument name="method" value="#local.ar#">
		</cfinvoke>
		<cfreturn this>
	</cffunction>
	<cffunction name="pdf" access="public" returntype="void">
		<cfset variables.type = "pdf">
	</cffunction>
	<cffunction name="excel" access="public" returntype="void">
		<cfset variables.type = "excel">
	</cffunction>
	
	<cffunction name="handle" access="public" returntype="void">
		<cfargument name="conn" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.ar = ArrayNew(1)>
		<cfset local.ar[1] = this>
		<cfset local.ar[2] = "convert">
		<cfset ARGUMENTS.conn.event.attach("beforeOutput",local.ar)>
	</cffunction>
	
	
	<cffunction name="as_file" access="private" returntype="void">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="inline" type="boolean" required="yes">
		<cfset var local = structNew()>
		<cfif variables.type eq "pdf">
			<cfset local.type = "application/pdf">
		<cfelseif variables.type eq "excel">
			<cfset local.type = "application/msexcel">
		<cfelse>	
			<cfset local.type = "application/force-download">
			<cfset ARGUMENTS.inline = false>
		</cfif>
		<cfif ARGUMENTS.inline>
			<cfheader name="Content-Type" value="#local.type#">
			<cfheader name="Content-Disposition" value="inline; filename='#getFileFromPath(ARGUMENTS.name)#';">
			<cfcontent file="#ARGUMENTS.name#" type="#local.type#"><cfabort>
		<cfelse>
			<cfheader name="Content-Disposition" value="attachment; filename='#getFileFromPath(ARGUMENTS.name)#';">
			<cfcontent file="#ARGUMENTS.name#" type="application/force-download"><cfabort>
		</cfif> 	
	</cffunction>
	
	
	<cffunction name="convert" access="public" returntype="void">
		<cfargument name="conn" type="any" required="yes">
		<cfargument name="out" type="any" required="yes">
		<cfset var local = structNew()>
		<cfhttp method="post" url="#variables._url#" throwonerror="yes" result="local.result">
			<cfhttpparam type="formfield" name="grid_xml" value="#ARGUMENTS.out.get_output()#">
		</cfhttp>
		<cfset local.f = CreateObject("java","java.io.File").init(variables.name)>
		<cfset local.o = CreateObject("java","java.io.FileOutputStream").init(local.f)>
		<cfset local.o.write(local.result.fileContent.toByteArray())>
		<cfset local.o.close()>
		<cfset as_file(variables.name,variables.inline)>
	</cffunction>
</cfcomponent>
