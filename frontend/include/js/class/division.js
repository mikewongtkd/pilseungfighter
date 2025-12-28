PilseungFighter.Division = class PSFDivision extends PilseungFighter.Class {
	constructor( doc = null ) {
		super( doc );
		if( doc === null ) {
			super();

		} else if( typeof doc == 'string' || typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instantiating a PilseungFighter.Division object` );
		}
	}
	get subject() { return 'division'; }

	get id()           { return this._data?.id; }
	get name()         { return this._data?.name; }
	get method()       { return this._data?.method; }
	get gender()       { return this._data?.gender; }
	get age()          { return this._data?.age; }
	get weight()       { return this._data?.weight; }
	get rank()         { return this._data?.rank; }
	get contestant()   { return this._data?.contestant; }
	get pss()          { return this._data?.pss; }
	get round()        { return this._data?.round; }
	get rest()         { return this._data?.rest; }
	get head_contact() { return this._data?.head; }
	get notes()        { return this._data?.notes; }
}
