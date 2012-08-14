var adminOnly = function( deniedTemplate, controller ) {
	var data, template, view;
	if ( request.sessionData.permissions.indexOf('write') != -1 ) {
		data = controller( );
		template = data[0];
		view = data[1];

		response.writeData( Mustache.render( template, view ) );
	} else {
		response.setStatusCode( 403 );
		view = { app_init_js: request.appInitScript };
		response.writeData( Mustache.render( deniedTemplate, view) );
	}
};

var render = function( controller ) {
	var data, template, view;

	data = controller( );
	template = data[0];
	view = data[1];

	response.writeData( Mustache.render( template, view ) );
};
