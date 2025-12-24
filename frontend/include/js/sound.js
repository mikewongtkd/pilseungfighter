PilseungFighter.Sound = class PSFSound {
	constructor() {
		let library = { ok : 'ok', error : 'error', next : 'next', prev : 'prev' };
		let formats = [ 'mp3', 'ogg' ];
		if( typeof Howl != 'function' ) {
			console.log( 'Please include Howl library in a <script> tag before using.' );
			return;
		}
		Object.keys( library ).forEach( sound => {
			let urls = [];
			let file = library[ sound ];
			formats.forEach( format => {
				urls.push( `/sounds/${file}.${format}` );
			});
			this[ sound ] = new Howl({ src: urls });
		});
	}
}
