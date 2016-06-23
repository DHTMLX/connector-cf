<cfcomponent namespace="FileTreeDataItem" extends="TreeDataItem">
	<cffunction name="init" access="public" returntype="any" hint="creates a new object">
		<cfargument name="data" type="any" required="yes" hint="Data object">
		<cfargument name="config" type="any" required="yes" hint="Config object">
		<cfargument name="index" type="numeric" required="no" default="1" hint="Index of an element">
		<cfset super.init(ARGUMENTS.data,ARGUMENTS.config,ARGUMENTS.index)>
		<cfreturn this>
	</cffunction>
	<cffunction name="has_kids" access="public" returntype="boolean">
		<cfif variables.data['is_folder'] eq '1'>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
</cfcomponent>
