<cfset options = {
	root_http = "../samples/",
	root = expandPath("../samples/"),
	index_template = expandPath("template_index.html"),
	
	pack_folder = expandPath("../"),
	pack_zip = expandPath("../dhtmlxConnectors_cfm_v1.0_beta.zip")
}>
<cfset connectors = CreateObjecT("component","dhtmlXConnectors").init(options)>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link rel="stylesheet" type="text/css" href="main.css" />
	<title>Untitled Document</title>
	<script>
		function check(main,prefix){
			var ch = main.form.elements;
			for (var i=0; i<ch.length; i++){
				if (ch[i].type=="checkbox" && ch[i].name && ch[i].name.indexOf(prefix)>-1){
					ch[i].checked = main.checked;
				};
			};
		};
	</script>
</head>
<body style="background-color:white;">
<cfoutput>
<cfif isDefined("form.samples")>
	<cfparam name="form.types" default="">
	<cfif isDefined("form.update")>
		<cfloop list="#form.types#" index="tp">
			<cfset connectors.save_custom_data(form,tp)>
		</cfloop>
	</cfif>
	<cfset files = connectors.collect_samples()>
	<form action="?requestTimeout=600" method="post">
	<input type="hidden" name="samples" value="1" />
	<input type="hidden" name="update" value="1" />
	
	<input type="submit" value="Save" />
	<cfloop collection="#files#" item="type">
 		<table border="1" class="main_table" >
		<cfset rows = ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(files[type])#" index="i">
			<cfif i eq 1>
				<!--- index.html --->
				<tr class="header">
					<td width="300px"><input type="checkbox" name="types" value="#type#" <cfif ListFindNoCase(form.types,type)>checked="checked" </cfif>/><a href="#options.root_http##files[type][i]#" target="_blank">#files[type][i]#</a></td>
					<td width="100px">Connector correct</td>
					<td width="500px">Include in index.html</td>
					<td width="150px">Add CODE to html <input type="checkbox" onclick="check(this,'codeadd_')"/></td>
					<td width="170px">DELETE CODE from html <input type="checkbox" onclick="check(this,'codedel_')"/></td>
				</tr>
				<tr class="long_tr">
					<td colspan="5">
						<cfset data = connectors.get_index_data(files[type][i])>
						Index Header: <input type="text" class="big" value="#data.title#"  name="indexheader_#type#"/>
						<br />
						Description:<br />
						<textarea name="indexdescription_#type#" class="big">#data.description#</textarea>
					</td>
				</tr>
			<cfelse>
				<cfset error_msg = connectors.connector_correct(files[type][i])>
				<cfset sample_info = connectors.get_sample_data(files[type][i],type)>
				<cfsavecontent variable="tmp">
					<td><a href="#options.root_http##files[type][i]#" target="_blank">#files[type][i]#</a></td>
					<td><cfif error_msg eq ""><div class="ok">Ok</div><cfelse><div class="error">#error_msg#</div></cfif></td>
					<td><input type="checkbox" name="index_#type#_#i#" value="1" <cfif sample_info.found>checked="checked"</cfif>/>&nbsp; Order: <input class="small" type="text" name="order_#type#_#i#" value="#sample_info.order#"/>&nbsp; Label: <input class="big" type="text" name="label_#type#_#i#" value="#sample_info.label#"/></td>
					<td><cfif sample_info.code_found><span class="ok">Code Found</span><cfelse><span class="error">Code NOT Found</span></cfif><input type="checkbox" name="codeadd_#type#_#i#" value="1"/></td>
					<td><input type="checkbox" name="codedel_#type#_#i#" value="1"/></td>
				</cfsavecontent>	
				<cfset row = {
					order = sample_info.order,
					content = tmp,
					found = sample_info.found
				}>
				<cfset local.inserted = false>
				<cfloop from="1" to="#ArrayLen(rows)#" index="j">
					<cfif rows[j].order gt row.order>
						<cfset ArrayInsertAt(rows,j,row)>
						<cfset local.inserted = true>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfif not local.inserted>
					<Cfset ArrayAppend(rows,row)>
				</cfif>
			</cfif>	
		</cfloop>
		<!--- draw rows in correct order now --->
		<cfloop from="1" to="#ArrayLen(rows)#" index="i">
			<cfif i mod 2>
				<cfset cl = "even">
			<cfelse>
				<cfset cl = "uneven">	
			</cfif>
			<cfif NOT rows[i].found>
				<cfset cl = cl & " disabled">
			</cfif>
			<tr class="#cl#">
				#rows[i].content#
			</tr>
		</cfloop>	
		
		</table>
		<div class="divider"></div>
	</cfloop>	
	<input type="submit" value="Save" />
	</form> 
</cfif>
<cfif isDefined("form.pack")>
	<cfset connectors.pack()>
	Pack was done.
</cfif>
</cfoutput>
</body>
</html>
