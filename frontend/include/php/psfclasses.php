<?php
include_once( __DIR__ . '/framework.php' );

class PSFClasses extends WebFramework {
	private const DEPENDENCIES = [
		'contestant' => [ 'class' ],
		'clock' => [ 'class' ],
		'clockUpdate' => [ 'clock' ],
		'division' => [ 'contestant' ],
		'judge' => [],
		'match' => [ 'matchRound', 'ring', 'contestant', 'division' ],
		'matchRound' => [ 'clock', 'score' ],
		'ring' => [ 'class' ],
		'score' => [ 'contestant' ],
		'scoreUpdate' => [ 'score' ]
	];

	public function __construct( $includes ) {

		$order = [];
		foreach( $includes as $include ) {
			PSFClasses::_resolve( $include, $order );
		}
		$order   = array_unique( $order );
		$scripts = array_merge([ '/include/js/psf.js' ], array_map( function( $class ) { return "/include/js/class/{$class}.js"; }, $order ));

		parent::__construct( $scripts, []);
	}

	private static function _resolve( $include, &$order ) {
		if( ! array_key_exists( $include, PSFClasses::DEPENDENCIES )) { 
			$order []= $include;

		} else {
			$dependencies = PSFClasses::DEPENDENCIES[ $include ];
			foreach( $dependencies as $dependency ) {
				PSFClasses::_resolve( $dependency, $order );
				$order []= $dependency;
			}
			$order []= $include;
		}
	}
}
