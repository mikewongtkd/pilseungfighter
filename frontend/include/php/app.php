<?php
include_once( __DIR__ . '/framework.php' );
include_once( __DIR__ . '/bootquery.php' );

class AppFramework extends WebFramework {
	public function __construct() {
		parent::__construct(
			[ 
				'/node_modules/howler/dist/howler.min.js', 
				'/include/js/psf.js',
				'/include/js/uuid.js',
				'/include/js/websocket.js',
				'/include/js/sound.js',
				'/include/js/event.js',
				'/include/js/app.js',
				'/include/js/widget.js'
			],
			[
			]
		);

		$bootquery = new BootQueryFramework();
		$this->requires( $bootquery );
	}
}

?>
