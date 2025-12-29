PilseungFighter.App = class PSFApp {
	constructor( ring = null ) {
		this._id       = UUID.v4();
		this._ring     = ring;
		this._alertify = alertify;
		this._button   = {};
		this._debug    = false;
		this._display  = {};
		this._input    = {};
		this._modal    = {};
		this._network  = new PilseungFighter.WebSocket( this );
		this._refresh  = {};
		this._sound    = new PilseungFighter.Sound();
		this._state    = {};
		this._page     = {};
		this._widget   = {};
		this.on        = {
			connect : url => {
				this._network.set( url );
				return this;
			}
		};

		// Alertify defaults
		alertify.defaults.theme.ok     = "btn btn-success";
		alertify.defaults.theme.cancel = "btn btn-warning";

		// Event Handler
		this._event = new PilseungFighter.EventServer( this );

		// Server Ping behavior
		this.ping = {};
		this.ping.off = () => { this.network.comms?.heard( 'client' ).command( 'ping' ).respond(() => { this.network.send({ subject : 'server', action : 'stop ping', ring }); }); }
		this.ping.on  = () => {
			this.network.comms.add( 'client', 'ping', ping => {
				let timestamp = Math.floor( Date.now() / 1000 );
				let pong = { subject : 'client', action : 'pong', ringid: ring, server : { ping : { timestamp : ping.server.timestamp }}, client : { pong : { timestamp }}};
				this.network.send( pong );
			});
		};

		// On Connect actions
		this.list = {
			ring : ( ring = 'staging' ) => { 
				let message = { subject : 'ring', action : 'list' };
				this._network.connect( message ); 
				this.ping.on(); 
			}
		};
		this.read = {
			division : ( divid = null ) => { 
				let message = { subject : 'division', action : 'search', division : { id : divid }}; 
				if( divid !== null ) { message.divid = divid };
				this._network.connect( message ); 
				this.ping.on(); 
			},
			ring : ( ring = 'staging' ) => { 
				let message = { subject : 'ring', action : 'search', ring : { ring }};
				this._network.connect( message ); 
				this.ping.on(); 
			}
		};
	}

	get alertify() { return this._alertify; }
	get button()   { return this._button; }
	get debug()    { return this._debug; }
	get display()  { return this._display; }
	get event()    { return this._event; }
	get id()       { return this._id; }
	get input()    { return this._input; }
	get modal()    { return this._modal; }
	get network()  { return this._network; }
	get page()     { return this._page; }
	get refresh()  { return this._refresh; }
	get ring()     { return this._ring; }
	get sound()    { return this._sound; }
	get state()    { return this._state; }
	get widget()   { return this._widget; }


	// App caches for general UI/UX usage
	set button( value )  { this._button  = value; } // For button behavior
	set debug( value )   { this._debug   = value; } // value := true|false
	set display( value ) { this._display = value; } // To reference general display components
	set input( value )   { this._input   = value; } // For input behavior
	set page( value )    { this._page    = value; } // For multipaged apps
	set refresh( value ) { this._refresh = value; } // Callbacks for app component behavior
	set state( value )   { this._state   = value; } // For app state (e.g. DFA graphs and transitions)
	set widget( value )  { this._widget  = value; } // Widgets

	request( request ) {
		this._network.connect( request );
	}
}
