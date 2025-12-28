PilseungFighter.Clock = class PSFClock extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'string' ) {
			if( PilseungFighter.isUUID( doc )) {
				super( doc );

			} else {
				super();
				this.name = doc;
			}

		} else if( typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instantiating a PilseungFighter.Clock object` );
		}
	}

	get name()     { return this._data?.name; }
	get start()    { return this._data?.start; }
	get finish()   { return this._data?.finish; }
	get duration() { return this._data?.duration; }
	get current()  { return this._data?.current; }
	get status()   { return this._data?.status; }

	set name( value ) { this._data.name = value; }
}
