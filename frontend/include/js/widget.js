PilseungFighter.Widget = class PSFWidget {
	constructor( app, dom, options = null ) {
		this._id      = UUID.v4();
		this._refresh = {};
		this._app     = app;
		this._button  = {};
		this._display = {};
		this._dom     = dom.match( /^#/ ) ? $( dom ) : $( `#${dom}` );
		this._input   = {};
		this._options = options;
		this._select  = {};
		this._sound   = app.sound;
		this._state   = {};
		this._comms   = new PilseungFighter.Comms( this, this.app.network );
		this._event   = new PilseungFighter.EventClient( this );

		this._cookie  = { 
			name: this.constructor.name, 
			value: () => {
				return $.cookie( this.cookie.name );
			},
			remove: () => {
				$.removeCookie( this.cookie.name );
			},
			save: ( data = null ) => {
				$.cookie.json = true;
				if( data === null ) {
					$.cookie( this.cookie.name, clone );
				} else {
					$.cookie( this.cookie.name, data );
				}
			}
		};
		this.network  = {
			on : {
				heard : subject => { return this.comms.heard( subject ); }
			},
			send : message => { return this.app.network.send( message ); }
		};
		this.listen( app.network );
	}

	listen( network ) {
		network.register( this );
	}

	heard( subject ) {
		return this._app.network.comms.heard( subject );
	}

	restore() {
		this.state = $.cookie( this.cookie );
	}

	save( data = null ) {
		$.cookie.json = true;
		if( data === null ) {
			$.cookie( this.cookie, this.state );
		} else {
			$.cookie( this.cookie, data );
		}
	}

	get app()     { return this._app; }
	get button()  { return this._button; }
	get comms()   { return this._comms; }
	get cookie()  { return this._cookie; }
	get display() { return this._display; }
	get dom()     { return this._dom; }
	get event()   { return this._event; }
	get id()      { return this._id; }
	get input()   { return this._input; }
	get refresh() { return this._refresh; }
	get select()  { return this._select; }
	get sound()   { return this._sound; }
	get state()   { return this._state; }

	set refresh( value ) { this._refresh = value; }
	set state( value )   { this._state = value; }
}
