PilseungFighter.Ring = class PSFRing extends PilseungFighter.Class {
	static volatile( id ) {
		let ring = new PilseungFighter.Ring();
		ring.id = id;
		return ring;
	}

	get id() { return this._data?.id; }
	get code() {
		if( this.id == 'staging' ) { return this.id; }
		let ringid = parseInt( this.id );
		if( ringid < 10 ) { return `ring0${ringid}`; } else { return `ring${ringid}`; }
	}
	get name() {
		if( this.id == 'staging' ) { return 'Staging'; }
		return `Ring ${this.id}`;
	}

	get subject() {
		return 'ring';
	}

	set id( value ) { this._data.id = value; }
}
