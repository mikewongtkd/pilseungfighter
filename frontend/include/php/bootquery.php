<?php
include_once( __DIR__ . '/framework.php' );

class BootQueryFramework extends WebFramework {
	public function __construct() {
		parent::__construct(
			[ 
				'/node_modules/jquery/dist/jquery.min.js', 
				'/node_modules/bootstrap/dist/js/bootstrap.min.js'
			],
			[
				'/node_modules/bootstrap/dist/css/bootstrap.min.css',
				'/node_modules/%40fortawesome/fontawesome-free/css/all.min.css'
			]
		);
	}
}

?>
