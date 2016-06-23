<?php 
	require("../../../php/samples/config.php");
	require("../../../php/codebase/grid_connector.php");
	$res=mysql_connect($mysql_server,$mysql_user,$mysql_pass);
	mysql_select_db($mysql_db);
	
	$grid = new GridConnector($res);
	 
	$config = new GridConfiguration();
	 
		$config->setHeader("Item Name,Item CD");
		$config->attachHeader("Item Name Test,#rspan");
		$config->attachFooter("Item Name,Item CD", Array("background-color: #ff0000;", "background-color: #00ff00;"));
		$config->attachFooter("Item Name Test,#rspan", "background-color: #0000ff;color:white;");
		$config->setColIds("col1,col2");
		$config->setInitWidths('120,*');
		$config->setColSorting("connector,connector");
		$config->setColColor("null,#dddddd");
		$config->setColHidden("false,false");
		$config->setColTypes("ro,ed");
		$config->setColAlign('center,center');
	 
	$grid->set_config($config);
	$grid->render_table("grid50000","item_id","item_nm,item_cd");
?>