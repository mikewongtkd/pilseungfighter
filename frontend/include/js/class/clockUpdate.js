PilseungFighter.ClockUpdate = class PSFClockUpdate extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'string' ) {
			super();
			this.clock = doc;

		} else if( typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instantiating a PilseungFighter.ClockUpdate object` );
		}
	}

	get clock()    { return this._data?.clock; }
	get at()       { return this._data?.at; }
	get duration() { return this._data?.duration; }
	get action()   { return this._data?.action; }

	set clock( value )    { this._data.clock    = value; }
	set action( value )   { this._data.action   = value; }
	set duration( value ) { this._data.duration = value; }
}
