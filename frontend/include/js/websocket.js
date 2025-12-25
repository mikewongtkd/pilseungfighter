PilseungFighter.Comms = class PSFComms {
	constructor( listener, websocket ) {
		this.context   = { type : null, action : []};
		this.table     = {}; // Dispatch table
		this.listener  = listener;
		this.websocket = websocket;
		this.log       = {};
		this._catch    = error => console.log( error );
		this.debug     = 1; // 0 to disable, 1 for basic information, 2 for more detailed information
	}

	add( type, action = null, handler = null ) {
		this.heard( type );
		if( action === null ) {
			action = 'update';
			handler = update => {
				try {
					this.dispatch( type, action, update );
				} catch( error ) {

					this._catch( error );
				}
			}

		} else if( handler === null ) {
			handler = update => {};
		}
		this.table[ type ][ action ] = handler;
	}

	dispatch( type, action, update ) {
		// Ignore if there's no handler
		if( ! this.table?.[ type ]?.[ action ]) { 
			if( this.debug > 1 && type != 'server' && action != 'ping' ) {
				console.log( `[...${this.listener?.id?.substring( 32 )}] ${this.listener.constructor.name} is ignoring a ${type} ${action} network message`, update );
			}
			return; 
		}

		// Record the message
		if( ! this.log?.[ type ]) { this.log[ type ] = {}; }
		if( ! this.log?.[ type ]?.[ action ]) { this.log[ type ][ action ] = []; }
		if( update?.request && ! this.log?.[ type ]?.[ action ]) { this.log[ type ][ action ].push( update.request ); }

		// Execute handler from the dispatch table
		if( this.debug > 1 && type != 'server' && action != 'ping' ) {
			console.log( `[...${this.listener?.id?.substring( 32 )}] ${this.listener.constructor.name} is processing a ${type} ${action} network message` );
		}
		this.table[ type ][ action ]( update );
	}

	heard( type ) {
		if( !  this.table?.[ type ]) {
			this.table[ type ] = {};
		}
		this.context.type = type;
		return this;
	}

	pass() {
		let handler = update => {};
		this.context.action.forEach( action => this.add( this.context.type, action, handler ));
		this.context.action = [];
		return this;
	}
	
	respond( handler ) {
		this.context.action.forEach( action => this.add( this.context.type, action, handler ));
		this.context.action = [];
		return this;
	}

	response( action ) {
		this.context.action.push( action );
		return this;
	}
};

PilseungFighter.WebSocket = class PSFWebSocket {
	constructor( listener ) {
		this.comms     = null;
		this.url       = null;
		this.ws        = null;
		this.listener  = listener;
		this.listeners = [];
	}

	connect( request ) {
		this.network = {
			open: () => {
				this.network.send( request );
			},
			message: response => { 
				let update  = JSON.parse( response.data );
				let type    = update.type;
				let action  = update.action;
				let request = update?.request;

				if( this.comms.debug > 0 && ! (type == 'server' && action == 'ping' )) {
					console.log( 'NETWORK MESSAGE', update );
				}

				// ------------------------------------------------------------
				// ENSURE THAT THE MESSAGE IS FOR THE GIVEN RING
				// ------------------------------------------------------------
				// Only the staging ring listens to all broadcasts
				let ring = { listener: this.listener?.ring, broadcast: null };
				ring.broadcast = [ update?.request?.ring, update?.ring?.name, update?.ring ].find( ring => {
					let is = {
						defined: typeof ring != 'undefined' && ring !== null,
						staging: typeof ring == 'string' && ring == 'staging',
						ringnum: Number.isInteger( ring )
					};
					return is.defined && (is.staging || is.ringnum);
				});
				if(( typeof ring.listener == 'undefined' || ring.listener === null ) && ring.listener != ring.broadcast && ring.listener != 'staging' ) {
					if( this.comms?.debug > 1 ) { console.log( `Ignoring message for ring ${ring.broadcast}`, update ); }
					return;
				}

				try {
					this.comms.dispatch( type, action, update );
					this.listeners.forEach( listener => listener.comms.dispatch( type, action, update ));
				} catch( error ) {
					this.comms._catch( error );
				}
			},
			send: data => {
				let request = { data };
				request.json = JSON.stringify( request.data ); 
				this.ws.send( request.json );
			}
		};
		this.comms = new PilseungFighter.Comms( this.listener, this );
		this.ws    = new WebSocket( this.url );
		this.ws.onopen    = this.network.open;
		this.ws.onmessage = this.network.message;
		this.on           = {
			heard : type => {
				return this.comms.heard( type );
			}
		};
	}

	catch( callback ) {
		this.comms._catch = callback;
	}

	close() {
		this.ws.close();
	}

	handle( response ) {
		let type   = response?.type;
		let action = response?.request?.action;
		this.comms.dispatch( type, action, response );
		this.listeners.forEach( listener => listener.comms.dispatch( type, action, response ));
	}

	reconnect( url ) {
		this.close();
		this.url = url;
		this.ws = new WebSocket( this.url );
		this.ws.onopen    = this.network.open;
		this.ws.onmessage = this.network.message;
	}

	register( listener ) {
		this.listeners.push( listener );
	}

	send( message ) {
		this.network.send( message );
	}

	set( url ) {
		this.url = url;
	}
}
