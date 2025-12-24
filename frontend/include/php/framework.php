<?php
class WebFramework {
	private static $listed = []; // Used to prevent echoing redundant link/script tags
	public $scripts;
	public $links;

	public function __construct( $scripts, $links ) {
		$this->scripts = $scripts;
		$this->links   = $links;
	}

	public function links() {
		foreach( $this->links as $link ) {
			if( ! in_array( $link, WebFramework::$listed )) {
				echo "\t<link href=\"{$link}\" />\n";
				WebFramework::$listed[]= $link;
			}
		}
	}

	public function requires( $framework ) {
		$this->scripts = array_merge( $framework->scripts, $this->scripts );
		$this->links   = array_merge( $framework->links, $this->links );
	}

	public function scripts() {
		foreach( $this->scripts as $script ) {
			if( ! in_array( $script, WebFramework::$listed )) {
				echo "\t<script src=\"{$script}\"></script>\n";
				WebFramework::$listed[]= $script;
			}
		}
	}
}
?>
