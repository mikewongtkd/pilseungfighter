PilseungFighter.Contestant = class PSFContestant extends PilseungFighter.Class {
	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'object' ) {
			super( doc );
		}
	}

	get subject() { return 'contestant'; }

	get dob()    { return this._data?.dob; }
	get gender() { return this._data?.gender; }
	get name()   { return this._data?.name; }
	get rank()   { return this._data?.rank; }
	get seed()   { return this._data?.seed; }
	get team()   { return this._data?.team; }
	get weight() { return this._data?.weight; }

	set dob( value )    { this._data.dob    = value; }
	set gender( value ) { this._data.gender = value; }
	set name( value )   { this._data.name   = value; }
	set rank( value )   { this._data.rank   = value; }
	set seed( value )   { this._data.seed   = value; }
	set team( value )   { this._data.team   = value; }
	set weight( value ) { this._data.weight = value; }

}
