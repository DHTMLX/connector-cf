<cfcomponent namespace="dhtmlXConnectors">
	<cfscript>
		variables.options = {
			root_http = "",
			root = "",
			index_template = "",
			
			pack_folder = "",
			pack_zip = ""
		};
	</cfscript>
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="options" type="struct" required="no" default=""> 
		<cfset var local = structNew()>
		<cfif isStruct(ARGUMENTS.options)>
			<cfset initOptions(ARGUMENTS.options)>
		</cfif>
		<cfreturn this>
	</cffunction>
	<cffunction name="initOptions" access="private" returntype="void">
		<cfargument name="options" type="struct" required="yes"> 
		<Cfset var local = structNew()>
		<cfloop collection="#ARGUMENTS.options#" item="local.opt">
			<cfset variables.options[local.opt] = ARGUMENTS.options[local.opt]>
		</cfloop>
	</cffunction>	
	
	<cffunction name="ArrayMerge" access="private" returntype="array">
		<cfargument name="ar1" type="array" required="yes">
		<cfargument name="ar2" type="array" required="yes">
		<cfset var local = structNew()>
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.ar2)#" index="local.i">
			<Cfset ArrayAppend(ARGUMENTs.ar1,ARGUMENTS.ar2[local.i])>
		</cfloop>
		<cfreturn ARGUMENTS.ar1>
	</cffunction>
	<cffunction name="arrayFind" access="public" returntype="numeric" hint="find value in array">
		<cfargument name="ar" type="array" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfset var local = structNew()>
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.ar)#" index="local.i">
			<cfif ARGUMENTS.ar[local.i] eq value>
				<cfreturn local.i>
			</cfif>
		</cfloop>
		<cfreturn 0>
	</cffunction>
	
	<!---------------- SAMPLES  ------------------->
	<cffunction name="get_files_samples" returntype="array" access="public" hint="recursive. Get the array of html files in the given folder">
		<cfargument name="dir" type="string" required="no" default="">
		<cfset var local = structNew()>
		<cfset local.files = ArrayNew(1)>
		<cfdirectory directory="#variables.options.root##ARGUMENTS.dir#" name="local.getDir">
		<cfloop query="local.getDir">
			<cfif local.getDir.type eq "dir">
				<cfset local.files = ArrayMerge(local.files,get_files_samples("#ARGUMENTS.dir##local.getDir.name#/"))>
			<cfelseif ListLast(local.getDir.name,".") eq "html">	
				<Cfset ArrayAppend(local.files,ARGUMENTS.dir & local.getDir.name)>
			</cfif>
		</cfloop>
		<Cfreturn local.files>
	</cffunction>
	<cffunction name="collect_samples" returntype="struct" access="public" hint="return collection where key is root folder name and value - is array of html files inside">
		<cfset var local = structNew()>
		<cfset local.files = get_files_samples()>
		<cfset local.result = structNew()>
		<cfloop from="1" to="#ArrayLen(local.files)#" index="local.i">
			<cfset local.pref = ListFirst(local.files[local.i],"/")>
			<cfif local.pref neq "index.html">
				<cfif not structKeyExists(local.result,local.pref)>
					<cfset local.result[local.pref] = arrayNew(1)>
				</cfif>
				<cfif GetFileFromPath(local.files[local.i]) eq "index.html">
					<cfset ArrayPrepend(local.result[local.pref],local.files[local.i])>
				<cfelse>
					<cfset ArrayAppend(local.result[local.pref],local.files[local.i])>	
				</cfif>
			</cfif>	
		</cfloop>
		<cfreturn local.result>
	</cffunction>
	
	
	<cffunction name="get_connector_files" access="public" returntype="array" hint="return array with abs paths of connector files foe the given html file">
		<cfargument name="filePath" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.res = ArrayNew(1)>
		<cfset local.fileBase = ListDeleteAt(getFileFromPath(ARGUMENTS.filePath),ListLen(getFileFromPath(ARGUMENTS.filePath),"."),".")>
		<cfset local.dir = variables.options.root & getDirectoryFromPath(ARGUMENTS.filePath)>
		<cfdirectory name="local.getDir" directory="#local.dir#" filter="*.cfm">
		<cfloop query="local.getDir">
			<cfset local.fileBaseCFM = ListDeleteAt(local.getDir.name,ListLen(local.getDir.name,"."),".")>
			<cfif findNoCase(local.fileBase,local.fileBaseCFM) eq 1>
				<cfset ArrayAppend(local.res,local.dir & local.getdir.name)>
			</cfif>
		</cfloop>
		<cfreturn local.res>
	</cffunction>
	<cffunction name="connector_correct" access="public" returntype="string" hint="check is connector correctly installed in the html file (if there are links to cfm connectors it must exist)">
		<cfargument name="filePath" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.f_html = variables.options.root & ARGUMENTS.filePath>
		<cfset local.f_cfm_ar = get_connector_files(ARGUMENTS.filePath)>
		<cfset local.f_cfm_ar_small = ArrayNew(1)>
		<cfloop from="1" to="#arrayLen(local.f_cfm_ar)#" index="local.i">
			<cfset local.f_cfm_ar_small[local.i] = GetFileFromPath(local.f_cfm_ar[local.i])>
		</cfloop>
		<cfif ArrayLen(local.f_cfm_ar) eq 0>
			<cfreturn "CFM not found">
		</cfif>
		<cffile action="read" file="#local.f_html#" variable="local.html">
		<cfset local.start = 1>
		<cfloop condition="true">
			<cfset local.match = refindNoCase("([\w]*?)\.(cfm|php)",local.html,local.start,true)>
			<cfif local.match.pos[1]>
				<cfset local.p = mid(local.html,local.match.pos[1],local.match.len[1])>
				<cfif refindNoCase("<script[\w\W]*?#local.p#[\w\W]*?<\/script>",local.html)>
					<cfif NOT ArrayFind(local.f_cfm_ar_small,local.p)>
						<cfreturn "HTML contains incorrect connector">
					</cfif>
				</cfif>	
				<cfset local.start =local.match.pos[1]+local.match.len[1]>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfreturn "">
	</cffunction>
	
	
	<cffunction name="get_index_data" access="public" returntype="struct" hint="get header text of index file">
		<cfargument name="filePath" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.res = {
			title = "",
			description=""
		}>
		<cfset local.f = variables.options.root & ARGUMENTS.filePath>
		<cffile action="read" file="#local.f#" variable="local.html">
		
		<cfset local.match = refindnocase("<h2>([\w\W]*?)<\/h2>",local.html,1,true)>
		<cfif local.match.pos[1]>
			<cfset local.res.title = mid(local.html,local.match.pos[2],local.match.len[2])>
		</cfif>
		
		<cfset local.match = refindnocase("<div>([\w\W]*?)<\/div>",local.html,1,true)>
		<cfif local.match.pos[1]>
			<cfset local.res.description = mid(local.html,local.match.pos[2],local.match.len[2])>
		</cfif>
		
		<cfreturn local.res>
	</cffunction>	
	<cffunction name="get_sample_data" access="public" returntype="struct" hint="Return the data about the sample in the index.html file">
		<cfargument name="filePath" type="string" required="yes">
		<cfargument name="type" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.res = {
			found = false,
			label = "",
			order = 0,
			code_found = false
		}>
		<cfset local.f_index_html = variables.options.root & ARGUMENTS.type & "/index.html">
		<cfset local.f_html = variables.options.root & ARGUMENTS.filePath>
		<cfset local.connectors = get_connector_files(ARGUMENTS.filePath)>
		
		<!--- get position in index.html file --->
		<cffile action="read" file="#local.f_index_html#" variable="local.html">
		<cfset local.start = 1>
		<cfset local.counter = 1>
		<cfloop condition="true">
			<cfset local.match = refindnocase("<li><a href=""([\w\W]*?)"">([\w\W]*?)<\/a><\/li>",local.html,local.start,true)>
			<cfif local.match.pos[1]>
				<cfset local.href = mid(local.html,local.match.pos[2],local.match.len[2])>
				<cfset local.lbl = mid(local.html,local.match.pos[3],local.match.len[3])>
				<cfif (ARGUMENTS.type &"/" &  local.href) eq ARGUMENTS.filePath>
					<cfset local.res.found = true>
					<cfset local.res.label = local.lbl>
					<cfset local.res.order = local.counter>
					<cfbreak>
				</cfif>
				<cfset local.counter = local.counter+1>
				<cfset local.start =local.match.pos[1]+local.match.len[1]>
			<cfelse>
				<cfbreak>	
			</cfif>
		</cfloop>
		
		<!--- check is there code section in the sample html file --->
		<cffile action="read" file="#local.f_html#" variable="local.html">
		<cfset local.start = 1>
		<cfset local.counter = 1>
		<cfloop condition="true">
			<cfset local.match = refindnocase("<div class='code'>([\w\W]*?)<\/div>",local.html,local.start,true)>
			<cfif local.match.pos[1]>
				<cfset local.code = mid(local.html,local.match.pos[2],local.match.len[2])>
				<cfset local.found = true>
				<cfloop from="1" to="#ArrayLen(local.connectors)#" index="local.i">
					<cfif not findNocase(getFileFromPath(local.connectors[local.i]),local.code)>
						<cfset local.found = false>
					</cfif>
				</cfloop>
				<cfset local.res.code_found = local.found>
				<cfset local.start =local.match.pos[1]+local.match.len[1]>
			<cfelse>
				<cfbreak>	
			</cfif>
		</cfloop>
		<cfreturn local.res>
	</cffunction>
	
	<cffunction name="save_custom_data" access="public" returntype="void" hint="Fix the index.html files">
		<cfargument name="form_data" type="struct" required="yes">
		<cfargument name="type" type="string" required="no" default="">
		<cfset var local = structNew()>
		<cfset local.files = collect_samples()>
		<cfset local.result = structNew()>
		<cfloop collection="#local.files#" item="local.type">
			<cfset local.index = {
				header = "",
				links = ArrayNew(1) 
			}>
			<cfloop from="1" to="#ArrayLen(local.files[local.type])#" index="local.i">
				<cfif local.i eq 1>
					<!--- index.html --->
					<cfif structKeyExists(ARGUMENTS.form_data,"indexheader_#local.type#")>
						<cfset local.index.header = ARGUMENTS.form_data["indexheader_#local.type#"]>
						<cfset local.index.description = ARGUMENTS.form_data["indexdescription_#local.type#"]>
					</cfif>
				<cfelse>
					<cfset local.s = {
						order = 0,
						label = 0,
						incl = 0,
						href = ListDeleteAt(local.files[local.type][local.i],1,"\/"),
						codeadd = 0,
						codedel = 0
					}>
					<cfif structKeyExists(ARGUMENTS.form_data,"index_#local.type#_#local.i#")>
						<cfset local.s.incl = 1>
					</cfif>
					<cfif structKeyExists(ARGUMENTS.form_data,"label_#local.type#_#local.i#")>
						<cfset local.s.label = ARGUMENTS.form_data["label_#local.type#_#local.i#"]>
					</cfif>
					<cfif structKeyExists(ARGUMENTS.form_data,"order_#local.type#_#local.i#")>
						<cfset local.s.order = ARGUMENTS.form_data["order_#local.type#_#local.i#"]>
					</cfif>
					<cfif structKeyExists(ARGUMENTS.form_data,"codeadd_#local.type#_#local.i#")>
						<cfset local.s.codeadd = 1>
					</cfif>
					<cfif structKeyExists(ARGUMENTS.form_data,"codedel_#local.type#_#local.i#")>
						<cfset local.s.codedel = 1>
					</cfif>
					
					<!--- include in the correct place in array --->
					<cfif local.s.incl>
						<cfset local.inserted = false>
						<cfloop from="1" to="#ArrayLen(local.index.links)#" index="local.j">
							<cfif local.index.links[local.j].order gt local.s.order>
								<cfset ArrayInsertAt(local.index.links,local.j,local.s)>
								<cfset local.inserted = true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif not local.inserted>
							<Cfset ArrayAppend(local.index.links,local.s)>
						</cfif>
					</cfif>	
					
					<cfif local.s.codeadd AND NOT local.s.codedel>
						<cfset insert_sample_code(local.files[local.type][local.i])>					
					</cfif>
					<cfif local.s.codedel>
						<cfset delete_sample_code(local.files[local.type][local.i])>					
					</cfif>
				</cfif>
			</cfloop>
			<cfif ARGUMENTS.type eq "" OR ARGUMENTS.type eq local.type>
				<cfset local.result[local.type] = duplicate(local.index)>
			</cfif>
		</cfloop>	
		
		<!--- do update the html --->
		<cffile action="read" file="#variables.options.index_template#" variable="local.template">
		<cfloop collection="#local.result#" item="local.type">
			<cfset local.f_index_html = variables.options.root & local.type & "\index.html">
			<cfset local.content = local.template>
			<cfset local.links = "">
			<cfloop from="1" to="#ArrayLen(local.result[local.type].links)#" index="local.i">
				<cfset local.links = local.links & "<li><a href=""#local.result[local.type].links[local.i].href#"">#local.result[local.type].links[local.i].label#</a></li>#chr(13)##chr(10)#">
			</cfloop>
			<cfset local.content = replaceNocase(local.content,"[HEADER]","<h2>#local.result[type].header#</h2>","all")>
			<cfset local.content = replaceNocase(local.content,"[DESCRIPTION]","<div>#local.result[type].description#</div>","all")>
			<cfset local.content = replaceNocase(local.content,"[LINKS]",local.links,"all")>
			<cffile action="write" file="#local.f_index_html#" output="#local.content#" nameconflict="overwrite">
		</cfloop>
	</cffunction>	
	
	<cffunction name="insert_sample_code" access="public" returntype="void" hint="Insert the formatted 'code' into the html file">
		<cfargument name="filePath" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.f_html = variables.options.root & ARGUMENTS.filePath>
		<cfset local.connectors = get_connector_files(ARGUMENTS.filePath)>
		
		<cffile action="read" file="#local.f_html#" variable="local.html">
		<cfset local.html = rereplacenocase(local.html,"<div class='code'>([\w\W]*?)<\/div>[#chr(13)##chr(10)#]*","","all")>
		<cfset local.connector_html = "">
		<cfloop from="1" to="#ArrayLen(local.connectors)#" index="local.i">
			<cffile action="read" file="#local.connectors[local.i]#" variable="local.connector">
			<cfset local.connector_html = local.connector_html & formatCFMCode(getFileFromPath(local.connectors[local.i]),local.connector) & "<br/>">
		</cfloop>
		<cfset local.html = replacenocase(local.html,"</body>","<div class='code'>"&local.connector_html&"</div>#chr(13)##chr(10)#</body>","one")>
		<cffile action="write" file="#local.f_html#" output="#local.html#" nameconflict="overwrite">
	</cffunction>	
	<cffunction name="delete_sample_code" access="public" returntype="void" hint="Deletes the formatted 'code' from the html file">
		<cfargument name="filePath" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.f_html = variables.options.root & ARGUMENTS.filePath>
		<cfset local.connectors = get_connector_files(ARGUMENTS.filePath)>
		
		<cffile action="read" file="#local.f_html#" variable="local.html">
		<cfset local.html = rereplacenocase(local.html,"<div class='code'>([\w\W]*?)<\/div>[#chr(13)##chr(10)#]*","","all")>
		<cffile action="write" file="#local.f_html#" output="#local.html#" nameconflict="overwrite">
	</cffunction>
	<cffunction name="formatCFMCode" access="public" returntype="string" hint="colorize the code">
		<cfargument name="title" type="string" required="yes">
		<cfargument name="code" type="string" required="yes">
		<cfset var local = structNew()>
		<cfset local.result = ARGUMENTS.code>
		<cfset local.result = rereplacenocase(local.result,"<\!---([\w\W]*?)--->","","all")>
		<cfset local.result = rereplacenocase(local.result,"[#chr(13)##chr(10)#]+","#chr(13)##chr(10)#","all")>
		<cfset local.coldFish = CreateObject("component","coldfish.coldfish").init()>
		<cfset local.result = local.coldFish.formatString(local.result)>
		<cfset local.result = '<span style="color:##000000; font-size:18px; text-decoration:underline; font-weight:bold;">#ARGUMENTS.title#: </span><br/><code>#local.result#</code>'>
		<cfreturn local.result>
	</cffunction>
	<!------------------- END SAMPLES --------------------->
	
	<!------------------- PAck --------------------->
	<cffunction name="pack" access="public" returntype="void" hint="Pack the files into archive. Only necesary files.">
		<cfset var local = structNew()>
		<cfset local.pack_dir = getFileFromPath(variables.options.pack_zip)>
		<cfset local.pack_dir = ListDeleteAt(local.pack_dir,ListLen(local.pack_dir,"."),".")>
		<cfset local.pack_dir = variables.options.pack_folder & local.pack_dir & "\">
		
		<cfif not directoryExists(local.pack_dir)><cfdirectory action="create" directory="#local.pack_dir#"></cfif>
		<cfif not directoryExists(local.pack_dir & "samples\")><cfdirectory action="create" directory="#local.pack_dir#samples\"></cfif>
		<cfif not directoryExists(local.pack_dir & "codebase\")><cfdirectory action="create" directory="#local.pack_dir#codebase\"></cfif>
		
		<!--- codebase --->
		<cfdirectory directory="#local.pack_dir#codebase\" name="local.getDir">
		<cfloop query="local.getDir">
			<cfif local.getDir.type eq "file">
				<cffile action="delete" file="#local.pack_dir#codebase\#local.getDir.name#">
			</cfif>
		</cfloop>
		<cfdirectory directory="#variables.options.pack_folder#codebase\" name="local.getDir">
		<cfloop query="local.getDir">
			<cfif local.getDir.type eq "file">
				<cffile action="copy" source="#variables.options.pack_folder#codebase\#local.getDir.name#" destination="#local.pack_dir#codebase\#local.getDir.name#" nameconflict="overwrite">
			</cfif>
		</cfloop>
		
		<!--- samples --->
		<cfif not directoryExists(local.pack_dir & "samples\db\")><cfdirectory action="create" directory="#local.pack_dir#samples\db\"></cfif>
		<cfdirectory directory="#local.pack_dir#samples\db\" name="local.getDir">
		<cfloop query="local.getDir">
			<cfif local.getDir.type eq "file">
				<cffile action="delete" file="#local.pack_dir#samples\db\#local.getDir.name#">
			</cfif>
		</cfloop>
		<cfloop list="msaccess_sampleDB.mdb,my_sql_sampledb.sql,mssql_sampleDB.bak" index="local.smpl">
			<cffile action="copy" source="#variables.options.pack_folder#samples\#local.smpl#" destination="#local.pack_dir#samples\db\#local.smpl#" nameconflict="overwrite">
		</cfloop>
		
		<!--- root samples folder --->
		<cfloop list="index.html,config.cfm,readme.txt" index="local.smpl">
			<cffile action="copy" source="#variables.options.pack_folder#samples\#local.smpl#" destination="#local.pack_dir#samples\#local.smpl#" nameconflict="overwrite">
		</cfloop>
		
		<!--- samples folders --->
		<cfloop list="combo,dataview,grid,tree,treegrid,scheduler,scheduler\recurring_events" index="local.smpl">
			<cfif not directoryExists("#local.pack_dir#samples\#local.smpl#\")><cfdirectory action="create"  directory="#local.pack_dir#samples\#local.smpl#\"></cfif>
			
			<cfdirectory directory="#local.pack_dir#samples\#local.smpl#\" name="local.getDir">
			<cfloop query="local.getDir">
				<cfif local.getDir.type eq "file">
					<cffile action="delete" file="#local.pack_dir#samples\#local.smpl#\#local.getDir.name#">
				</cfif>
			</cfloop>
			<cfdirectory directory="#variables.options.pack_folder#samples\#local.smpl#\" name="local.getDir">
			<cfloop query="local.getDir">
				<cfif local.getDir.type eq "file" AND ListFindNoCase("htm,html,cfm",ListLast(local.getDir.name,"."))>
					<cffile action="copy" source="#variables.options.pack_folder#samples\#local.smpl#\#local.getDir.name#" destination="#local.pack_dir#samples\#local.smpl#\#local.getDir.name#" nameconflict="overwrite">
				</cfif>
			</cfloop>
		</cfloop>
		
		<!--- samples common folder --->
		<cfloop list="common,common\imgs,common\types" index="local.smpl">
			<cfif not directoryExists("#local.pack_dir#samples\#local.smpl#\")><cfdirectory action="create"  directory="#local.pack_dir#samples\#local.smpl#\"></cfif>
			<cfdirectory directory="#local.pack_dir#samples\#local.smpl#" name="local.getDir">
			<cfloop query="local.getDir">
				<cfif local.getDir.type eq "file">
					<cffile action="delete" file="#local.pack_dir#samples\#local.smpl#\#local.getDir.name#">
				</cfif>
			</cfloop>
			<cfdirectory directory="#variables.options.pack_folder#samples\#local.smpl#\" name="local.getDir">
			<cfloop query="local.getDir">
				<cfif local.getDir.type eq "file" AND ListFindNoCase("htm,html,js,css,gif,png",ListLast(local.getDir.name,"."))>
					<cffile action="copy" source="#variables.options.pack_folder#samples\#local.smpl#\#local.getDir.name#" destination="#local.pack_dir#samples\#local.smpl#\#local.getDir.name#" nameconflict="overwrite">
				</cfif>
			</cfloop>
		</cfloop>	
		
			
	</cffunction>	
</cfcomponent>