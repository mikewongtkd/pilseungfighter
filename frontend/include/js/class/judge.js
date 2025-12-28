PilseungFighter.Judge = class PSFJudge {
	constructor( value = null ) {
		if( value === null || typeof value == 'number' ) {
			this._id = value;

		} else if( typeof value == 'string' && value.match( /^(?:ref(?:eree)?|j(?:udge\s*)?\d)$/i )) {
			this.code = value;

		} else {
			throw new Error( `Invalid value ${value} provided when instantiating PilseungFighter.Judge class` );
		}
	}

	get id() { return this._id; }
	get code() {
		if( this.id == 0 ) { return 'ref'; }
		return `j${this.id}`;
	}
	get name() {
		if( this.id == 0 ) { return 'Referee'; }
		return `Judge ${this.id}`;
	}

	set id( value ) { this._data.id = value; }
	set code( value ) {
		if( value == 'ref' ) { 
			this.id = 0;

		} else if( typeof value == 'string' && value.match( /^j/i )) {
			this.id = parseInt( value.toLowerCase().replace( /^j/, '' ));

		} else if( typeof value == 'number' ) {
			this.id = parseInt( value );
		}
	}
}
