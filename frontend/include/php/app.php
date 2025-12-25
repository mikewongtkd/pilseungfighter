<?php
include_once( __DIR__ . '/framework.php' );
include_once( __DIR__ . '/bootquery.php' );

class AppFramework extends WebFramework {
	public $config;

	public function __construct() {
		parent::__construct(
			[ 
				'/node_modules/alertifyjs/build/alertify.min.js', 
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
				'/node_modules/alertifyjs/build/css/alertify.min.css',
				'/node_modules/alertifyjs/build/css/themes/default.min.css',
				'/node_modules/alertifyjs/build/css/themes/semantic.min.css',
				'/node_modules/alertifyjs/build/css/themes/bootstrap.min.css'
			]
		);

		# Require Bootstrap and jQuery
		$bootquery = new BootQueryFramework();
		$this->requires( $bootquery );

		# Get PSF Config
		$config_file = '/usr/local/psf/config.json';
		if( file_exists( $config_file )) {
			$text = file_get_contents( $config_file );
			$this->config = json_decode( $text );
		} else {
			die( "Configuration file '{$config_file}' not found !" );
		}
	}

	public function websocket( $ring = 'staging', $role = 'admin' ) {
		$protocol = $this->config->protocol == 'https://' ? 'wss://' : 'ws://';
		$host     = $this->config->host;
		$port     = $this->config->port->psf;

		return "{$protocol}{$host}:{$port}/{$ring}/{$role}";
	}
}

?>
