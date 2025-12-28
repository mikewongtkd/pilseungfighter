PilseungFighter.Match = class PSFMatch extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instantiating a PilseungFighter.Match object` );
		}
	}

	get id()         { return this._data?.id; }
	get number()     { return this._data?.number; }
	get division()   { return this._data?.division; }
	get ring()       { return this._data?.ring; }
	get round()      { return this._data?.round; }
	get contestant() { return this._data?.contestant; }
	get winner()     { return this._data?.winner; }
	get start()      { return this._data?.start; }
	get finish()     { return this._data?.finish; }

	get chung()      { return this._data?.contestant?.[ 0 ]; }
	get hong()       { return this._data?.contestant?.[ 1 ]; }
}
