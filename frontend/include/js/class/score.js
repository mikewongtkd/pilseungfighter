PilseungFighter.Score = class PSFScore extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instantiating a PilseungFighter.Score object` );
		}
	}

	get contestant()    { return this._data?.contestant; }
	get presentation()  { return this._data?.presentation; }
	get technical()     { return this._data?.technical; }
	get deduction()     { return this._data?.deduction; }
	get penalty_timer() { return this._data?.penalty_timer; }
	get decision()      { return this._data?.decision; }
}
