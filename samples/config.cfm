<!--- just define datasources and connector paths --->
<cfset request.dhtmlxConnectors = StructNew()>
<!--- datasource to use in the samples --->
<cfset request.dhtmlxConnectors["datasource"] = "sampleDB">
<!--- DB type to use in samples. Available: MySQL,MSSQL,MSAccess --->
<cfset request.dhtmlxConnectors["db_type"] = "MySQL">
<!--- here are the Full Mappings to the directoy with connectors, including the connector component without cfc extention. --->
<cfset request.dhtmlxConnectors["combo"] = "dhtmlXConnectors.ComboConnector">
<cfset request.dhtmlxConnectors["tree_group"] = "dhtmlXConnectors.TreeGroupConnector">
<cfset request.dhtmlxConnectors["tree_multitable"] = "dhtmlXConnectors.TreeMultiTableConnector">
<cfset request.dhtmlxConnectors["tree"] = "dhtmlXConnectors.TreeConnector">
<cfset request.dhtmlxConnectors["options"] = "dhtmlXConnectors.OptionsConnector">
<cfset request.dhtmlxConnectors["grid"] = "dhtmlXConnectors.GridConnector">
<cfset request.dhtmlxConnectors["grid_config"] = "dhtmlXConnectors.GridConfiguration">
<cfset request.dhtmlxConnectors["treegrid"] = "dhtmlXConnectors.TreeGridConnector">
<cfset request.dhtmlxConnectors["treegrid_group"] = "dhtmlXConnectors.TreeGridGroupConnector">
<cfset request.dhtmlxConnectors["treegrid_multitable"] = "dhtmlXConnectors.TreeGridMultitableConnector">
<cfset request.dhtmlxConnectors["scheduler"] = "dhtmlXConnectors.SchedulerConnector">
<cfset request.dhtmlxConnectors["dataview"] = "dhtmlXConnectors.DataViewConnector">
<cfset request.dhtmlxConnectors["convert"] = "dhtmlXConnectors.ConvertService">

