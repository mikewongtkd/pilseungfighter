PilseungFighter.Comms = class PSFComms {
	constructor( listener, websocket ) {
		this.context   = { subject : null, action : []};
		this.table     = {}; // Dispatch table
		this.listener  = listener;
		this.websocket = websocket;
		this.log       = {};
		this._catch    = error => console.log( error );
		this.debug     = 1; // 0 to disable, 1 for basic information, 2 for more detailed information
	}

	add( subject, action = null, handler = null ) {
		this.heard( subject );
		if( action === null ) {
			action = 'update';
			handler = update => {
				try {
					this.dispatch( subject, action, update );
				} catch( error ) {

					this._catch( error );
				}
			}

		} else if( handler === null ) {
			handler = update => {};
		}
		this.table[ subject ][ action ] = handler;
	}

	dispatch( subject, action, update ) {
		// Ignore if there's no handler
		if( ! this.table?.[ subject ]?.[ action ]) { 
			if( this.debug > 1 && subject != 'server' && action != 'ping' ) {
				console.log( `[...${this.listener?.id?.substring( 32 )}] ${this.listener.constructor.name} is ignoring a ${subject} ${action} network message`, update );
			}
			return; 
		}

		// Record the message
		if( ! this.log?.[ subject ]) { this.log[ subject ] = {}; }
		if( ! this.log?.[ subject ]?.[ action ]) { this.log[ subject ][ action ] = []; }
		if( update?.request && ! this.log?.[ subject ]?.[ action ]) { this.log[ subject ][ action ].push( update.request ); }

		// Execute handler from the dispatch table
		if( this.debug > 1 && subject != 'server' && action != 'ping' ) {
			console.log( `[...${this.listener?.id?.substring( 32 )}] ${this.listener.constructor.name} is processing a ${subject} ${action} network message` );
		}
		this.table[ subject ][ action ]( update );
	}

	heard( subject ) {
		if( !  this.table?.[ subject ]) {
			this.table[ subject ] = {};
		}
		this.context.subject = subject;
		return this;
	}

	pass() {
		let handler = update => {};
		this.context.action.forEach( action => this.add( this.context.subject, action, handler ));
		this.context.action = [];
		return this;
	}
	
	respond( handler ) {
		this.context.action.forEach( action => this.add( this.context.subject, action, handler ));
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
				let subject = update.subject;
				let action  = update?.request?.action;
				let request = update?.request;

				if( this.comms.debug > 0 && ! (subject == 'server' && action == 'ping' )) {
					if( update?.error ) {
						console.log( 'SERVER ERROR', update );
						if( this.listener?.alertify && this.listener?.debug ) {
							this.listener.alertify.error( update.error );
						}
						return;
					}
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
					this.comms.dispatch( subject, action, update );
					this.listeners.forEach( listener => listener.comms.dispatch( subject, action, update ));
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
			heard : subject => {
				return this.comms.heard( subject );
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
		let subject = response?.subject;
		let action  = response?.request?.action;
		this.comms.dispatch( subject, action, response );
		this.listeners.forEach( listener => listener.comms.dispatch( subject, action, response ));
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
