PilseungFighter.DivisionRound = class PSFDivisionRound extends PilseungFighter.Class {
	const Name = {
		prelim: 'Preliminary Round',
		semfin: 'Semi-Final Round',
		finals: 'Final Round',
		ro2:    'Finals (Round of 2)',
		ro4:    'Semi-Finals (Round of 4)',
		ro8:    'Quarter-Finals (Round of 8)',
		ro16:   'Round of 16',
		ro32:   'Round of 32',
		ro64:   'Round of 64',
		ro128:  'Round of 128',
		ro256:  'Round of 256'
	};

	constructor( doc = null ) {
		if( doc === null ) {
			super();

		} else if( typeof doc == 'number' || typeof doc == 'string' ) {
			super();
			this.id = doc;

		} else if( typeof doc == 'object' ) {
			super( doc );

		} else {
			throw new Error( `Invalid parameter ${doc} when instantiating a PilseungFighter.DivisionRound object` );
		}
	}

	get name()       { let code = this.code; return PilseungFighter.DivisionRound.Name[ code ]; }
	get code()       { return this._data?.code; }
	get order()      { return this._data?.order; }
	get division()   { return this._data?.division; }
	get contestant() { return this._data?.contestant; }
};
