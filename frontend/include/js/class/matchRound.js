PilseungFighter.MatchRound = class PSFMatchRound extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instantiating a PilseungFighter.MatchRound object` );
		}
	}

	get match()   { return this._data?.match; }
	get number()  { return this._data?.number; }
	get clock()   { return this._data?.clock; }
	get kyeshi()  { return this._data?.kyeshi; }
	get medical() { return this._data?.medical; }
	get chung()   { return this._data?.chung; }
	get hong()    { return this._data?.hong; }
	get winner()  { return this._data?.winner; }
	get current() { return this._data?.current; }
}
