<cfcomponent namespace="EventInterface">
	<cfscript>
		//DataRequestConfig instance
		variables._request = ""; 
		//array of sorting rules
		this.rules = ArrayNew(1); 
	</cfscript>
	<cffunction name="init" access="public" returntype="any" hint="creates a new interface based on existing request">
		<cfargument name="_request" type="any" required="yes">
		<cfset variables._request = ARGUMENTS._request>
		<cfreturn this>
	</cffunction>
	<cffunction name="clear" access="public" returntype="void" hint="remove all elements from collection">
		<cfset ArrayClear(this.Rules)>
	</cffunction>
	<cffunction name="index" access="public" returntype="numeric" hint="get index by name">
		<cfargument name="name" type="string" required="yes">
		<cfreturn array_search(this.Rules,ARGUMENTS.name)>
	</cffunction>
	<cffunction name="array_search" access="public" returntype="numeric">
		<cfargument name="ar" type="array" required="yes">
		<cfargument name="value" type="string" required="yes">
		<cfset var i = 0>
		<cfloop from="1" to="#ArrayLen(ARGUMENTS.ar)#" index="i">
			<cfif ARGUMENTS.ar[i].name eq  ARGUMENTS.value>
				<cfreturn i>
			</cfif>
		</cfloop>
		<cfreturn 0>
	</cffunction>
</cfcomponent>

	