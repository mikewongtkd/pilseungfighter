PilseungFighter.CommsMessage = class PSFCommsMessage {
	constructor( parent ) {
		this.parent = parent;
	}

	create( data = null ) {
		let subject = this.subject;
		let message = { subject, action: 'write' };
		if( data === null ) {
			message[ subject ] = data;
		} else {
			message[ subject ] = this.data;
		}
		return message;
	}

	delete() {
		let subject = this.subject;
		let message = { subject, action: 'delete' };
		message[ subject ] = this.uuid;
		return message;
	}

	first( query ) {
		let subject = this.subject;
		let message = { subject, action: 'get one' };
		message[ subject ] = query;
		return message;
	}

	list() {
		return { subject: this.subject, action: 'list' };
	}

	read( uuid = null ) {
		let subject = this.subject;
		let message = { subject, action: 'read' };
		if( uuid === null ) {
			message[ subject ] = this.uuid;
		} else {
			message[ subject ] = uuid;
		}
		return message;
	}

	search( query ) {
		let subject = this.subject;
		let message = { subject, action: 'get' };
		message[ subject ] = query;
		return message;
	}

	update( data = null ) {
		let message = { subject: this.subject, action: 'write' };
		message[ this.subject ] = data === null ? this.data : data;
		return message;
	}

	get uuid()    { return this.parent.uuid; }
	get data()    { return this.parent.data; }
	get subject() { return this.parent.subject; }

};

PilseungFighter.Class = class PSFClass {
	constructor( instance = { 'class': null, uuid: null, data: {}} ) {
		this._message = new PilseungFighter.CommsMessage( this );

		if( typeof instance == 'string' && PilseungFighter.isUUID( instance )) {
			this._uuid = instance;

		} else if( typeof instance == 'object' ) {
			this._class   = instance.class;
			this._uuid    = instance.uuid;
			this._data    = instance.data;

		} else {
			throw new Error( `Invalid parameter ${instance} when instantiating a PilseungFighter.Class object` );
		}
	}

	get class()   { return this._class; }
	get data()    { return this._data; }
	get message() { return this._message; }
	get subject() { return ''; }
	get uuid()    { return this._uuid; }

	set message( subclass ) { this._message = subclass; }
}
