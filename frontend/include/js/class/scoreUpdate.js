PilseungFighter.ScoreUpdate = class PSFScoreUpdate extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'object' ) {
			super( doc );
		}
	}

	get subject() { return 'contestant'; }

	get score()        { return this._data?.score; }
	get from()         { return this._data?.from; }
	get to()           { return this._data?.to; }
	get presentation() { return this._data?.presentation; }
	get technical()    { return this._data?.technical; }
	get deduction()    { return this._data?.deduction; }
	get decision()     { return this._data?.decision; }

	set score( value )        { this._data.score  = value; }
	set from( value )         { this._data.from   = value; }
	set to( value )           { this._data.name   = value; }
	set presentation( value ) { this._data.rank   = value; }
	set technical( value )    { this._data.seed   = value; }
	set deduction( value )    { this._data.team   = value; }
	set decision( value )     { this._data.weight = value; }
}
