PilseungFighter.Class = class PSFClass {
	constructor( instance = { 'class': undef, uuid: undef, data: {}} ) {
		this._class = instance.class;
		this._uuid  = instance.uuid;
		this._data  = instance.data;
	}

	get class() { return this._class; }
	get uuid() { return this._uuid; }
}
