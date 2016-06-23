<cfcomponent namespace="DB_FileSystem" extends="DBDataWrapper" hint="Most execution time is a standart functions for workin with FileSystem: is_dir(), dir(), readdir(), stat()">
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="db" type="string" required="yes">
		<cfargument name="config" type="any" required="yes">
		<cfset super.init(ARGUMENTS.config,ARGUMENTS.db)>
		<cfreturn this>	
	</cffunction>
	<cffunction name="do_select" access="public" returntype="query" hint="returns list of files and directories">
		<cfargument name="source" type="any" required="yes">
		<cfset var local = structNew()>
		<cfset local.relation = getFileName(ARGUMENTS.source.get_relation())>
		<!--- for tree checks relation id and forms absolute path --->
		<cfset local.path = ARGUMENTS.source.get_source()>
		<cfset local.path = getFileName(local.path)>
		
		<cfif ReFindNoCase("\w\:\\",local.path) eq 1>
			<!--- abs path --->
			<cfset local.path = createPath(local.path & "\")>
		<cfelse>	
			<cfset local.path = createPath(expandPath(local.path) & "\")>
		</cfif>
		
		<cfif not directoryExists(local.path)>
			<cfreturn CreateObject("component","FileSystemResult").init().get_files()>
		</cfif>
		
		<cfif NOT FinDNoCase(local.path,createPath(local.path & local.relation))>
			<cfreturn CreateObject("component","FileSystemResult").init().get_files()>
		</cfif>
		<!--- gets files and directories list --->
		<cfset local.res = getFilesList(local.path, local.relation)>
		<!---  sorts list --->
		<cfset local.res = local.res.sort(ARGUMENTS.source.get_sort_by(), variables.config.data)>
		<cfreturn local.res>
	</cffunction>
	
	<cffunction name="getFilesList" access="private" returntype="any" hint="gets files and directory list">
		<cfargument name="path" type="string" required="yes">
		<cfargument name="relation" type="string" required="yes">
		<cfset var local = structNew()>
		<cfinvoke component="FileSystemTypes" method="getInstance" returnvariable="local.fileSystemTypes"></cfinvoke>
		<cfinvoke component="EventMaster" method="trigger_static">
			<cfinvokeargument name="name" value="Query filesystem: #ARGUMENTS.path#">
		</cfinvoke>
		
		<cfset local.dir =  createPath(ARGUMENTS.path  & ARGUMENTS.relation & "\")>
		
		<cfset local.result = CreateObjecT("component","FileSystemResult").init()>
		<!--- forms fields list --->
		<cfset local.fields = arrayNew(1)>
		<cfloop from="1" to="#ArrayLen(variables.config.data)#" index="local.i">
			<cfset ArrayAppend(local.fields,variables.config.data[local.i]['db_name'])>
		</cfloop>
		
		<!--- for every file and directory of folder --->
		<cfdirectory action="list" name="local.getDir" directory="#local.dir#">
		<cfloop query="local.getDir">
			<cfset local.newFile = structNew()>
			<!--- parse file name as Struct('name', 'ext', 'is_dir') --->
			<cfset local.fileNameExt = parseFileName(local.dir, local.getDir.name)>
			<!--- checks if file should be in output --->
			<cfif local.fileSystemTypes.checkFile(local.getDir.name, local.fileNameExt)>
				<!--- for every field forms list of fields --->
				<cfloop from="1" to="#ArrayLen(local.fields)#" index="local.i">
					<cfset local.field = local.fields[local.i]>
					<cfswitch expression="#local.field#">
						<cfcase value="filename">
							<cfset local.newFile['filename'] = local.getDir.name>
						</cfcase>	
						<cfcase value="full_filename">
							<cfset local.newFile['full_filename'] = local.dir & local.getDir.name>
						</cfcase>	
						<cfcase value="size">
							<cfset local.newFile['size'] = local.getDir.size>
						</cfcase>	
						<cfcase value="extention">
							<cfset local.newFile['extention'] = local.fileNameExt['ext']>
						</cfcase>	
						<cfcase value="name">
							<cfset local.newFile['name'] = local.fileNameExt['name']>
						</cfcase>	
						<cfcase value="date">
							<cfset local.newFile['date'] = DateFormat(local.getdir.dateLastModified) &" "& TimeFormat(local.getdir.dateLastModified,"HH:mm:ss")>
						</cfcase>	
					</cfswitch>
					<cfset local.newFile['relation_id'] = ARGUMENTS.relation & '/' & local.getDir.name>
					<cfset local.newFile['safe_name'] = setFileName(local.newFile['relation_id'])>
					<cfset local.newFile['is_folder'] = local.fileNameExt['is_dir']>
				</cfloop>
				<!--- add file in output list --->
				<cfset local.result.addFile(local.newFile)>
			</cfif>
		</cfloop>
		<cfreturn local.result>
	</cffunction>

	

	
	
	<cffunction name="setFileName" access="private" returntype="string" hint="replaces '.' and '_' in id">
		<cfargument name="filename" type="string" required="yes">   
		<cfset var local = structNew()>
		<cfset ARGUMENTS.fileName = replacenocase(ARGUMENTs.filename,".", "{-dot-}","all")>
		<cfset ARGUMENTS.filename = replaceNOcase(ARGUMENTs.filename,"_", "{-nizh-}","all")>
		<cfreturn ARGUMENTS.filename>
	</cffunction>
	<cffunction name="getFileName" access="private" returntype="string" hint="replaces '{-dot-}' and '{-nizh-}' in id">
		<cfargument name="filename" type="string" required="yes">   
		<cfset var local = structNew()>
		<cfset ARGUMENTS.fileName = replacenocase(ARGUMENTs.filename,"{-dot-}", ".","all")>
		<cfset ARGUMENTS.filename = replaceNOcase(ARGUMENTs.filename,"{-nizh-}", "_","all")>
		<cfreturn ARGUMENTS.filename>
	</cffunction>

	<cffunction name="parseFileName" access="public" returntype="struct" hint="parses file name and checks if is directory">
		<cfargument name="path" type="string" required="yes">   
		<cfargument name="file" type="string" required="yes">   
		<cfset var local = strucTnew()>
		
		<cfset local.result = structNew()>
		<cfif directoryExists(ARGUMENTS.path & "/" & ARGUMENTS.file)>
			<cfset local.result['name'] = ARGUMENTS.file>
			<cfset local.result['ext'] = 'dir'>
			<cfset local.result['is_dir'] = 1>
		<cfelse>
			<cfset local.result['name'] = ListDeleteAt(ARGUMENTS.file,ListLen(ARGUMENTs.file,"."),".")>
			<cfset local.result['ext'] = ListLast(ARGUMENTS.file,".")>
			<cfset local.result['is_dir'] = 0>
		</cfif>
		<cfreturn local.result>
	</cffunction>
	
	<cffunction name="query" access="public">
		<cfargument name="sql">  
	</cffunction>
	<cffunction name="get_new_id" access="public">
		<cfargument name="sql">  
	</cffunction>
	<cffunction name="escape" access="public" returntype="string">
		<cfargument name="data" type="string" required="no" default="">  
		<cfreturn ARGUMENTd.data>
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
	
	<cffunction name="createPath" access="private" returntype="string">
		<cfargument name="path" type="string" required="yes"> 
		<cfset ARGUMENTS.path = rereplacenoCase(ARGUMENTS.path,"[\\//]+","\","all")>
		<cfreturn ARGUMENTS.path>
	</cffunction>
</cfcomponent>
