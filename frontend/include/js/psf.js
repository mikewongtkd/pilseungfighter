class PilseungFighter {
	constructor() {
	};

	static isUUID( uuid ) {
		if( typeof uuid != 'string' ) { return false; }
		if( uuid.match( /^[0-9A-Za-z]{8}\-[0-9A-Za-z]{4}\-[0-9A-Za-z]{4}\-[0-9A-Za-z]{4}\-[0-9A-Za-z]{12}$/ )) { return true; }
		return false;
	}
};
