<cfcomponent namespace="FilterInterface" extends="EventInterface" hint="Wrapper for collection of filtering rules">
	<cffunction name="init" access="public" returntype="any" hint="creates a new interface based on existing request">
		<cfargument name="_request" type="any" required="yes" hint="DataRequestConfig object">
		<cfset variables._request = ARGUMENTS._request>
		<cfset this.rules = variables._request.get_filters()>
		<cfreturn this>
	</cffunction>
	<cffunction name="add" access="public" returntype="void" hint="add new filatering rule">
		<cfargument name="name" type="string" required="yes" hint="name of field">
		<cfargument name="value" type="string" required="yes" hint="value to filter by">
		<cfargument name="rule" type="any" required="no" default="" hint="filtering rule">
		<cfset variables._request.set_filter(ARGUMENTS.name,ARGUMENTS.value,ARGUMENTS.rule)>
		<cfset this.rules = variables._request.get_filters()>
	</cffunction>
	<cffunction name="store" access="public" returntype="void">
		<cfset variables._request.set_filters(this.rules)>
	</cffunction>
</cfcomponent>
