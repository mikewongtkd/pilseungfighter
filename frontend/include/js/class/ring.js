PilseungFighter.Ring = class PSFRing extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'number' || doc == 'staging' ) {
			super();
			this.id = doc;

		} else if( typeof doc == 'string' && PilseungFighter.isUUID( doc )) {
			super( doc );

		} else if( typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instatiating a PilseungFighter.Ring object.` );
		}
	}

	get id() { return this._data?.id; }
	get code() {
		if( this.id == 'staging' ) { return this.id; }
		let ringid = parseInt( this.id );
		if( ringid < 10 ) { return `ring0${ringid}`; } else { return `ring${ringid}`; }
	}
	get current() { return this._data?.current; }
	get judges() { return this._data?.judges; }
	get name() {
		if( this.id == 'staging' ) { return 'Staging'; }
		return `Ring ${this.id}`;
	}

	get subject() {
		return 'ring';
	}

	set id( value ) { this._data.id = value; }
}
