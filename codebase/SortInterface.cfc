<cfcomponent namespace="SortInterface" extends="EventInterface" hint="Wrapper for collection of sorting rules">
	<cffunction name="init" access="public" returntype="any" hint="creates a new interface based on existing request">
		<cfargument name="_request" type="any" required="yes" hint="DataRequestConfig object">
		<cfset super.init(ARGUMENTS._request)>
		<cfset this.rules = variables._request.get_sort_by()>
		<cfreturn this>
	</cffunction>
	<cffunction name="add" access="public" returntype="void" hint="add new sorting rule">
		<cfargument name="name" type="string" required="yes" hint="name of field">
		<cfargument name="dir" type="string" required="no" default="ASC" hint="direction of sorting">
		<cfset variables._request.set_sort(ARGUMENTS.name,ARGUMENTS.dir)>
		<cfset this.rules = variables._request.get_sort_by()>
	</cffunction>
	<cffunction name="store" access="public" returntype="void">
		<cfset variables._request.set_sort_by(this.rules)>
	</cffunction>
</cfcomponent>
