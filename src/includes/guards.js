var adminOnly = function( deniedTemplate, controller ) {
	var data, template, view;
	if ( request.sessionData.isAdmin ) {
		data = controller( );
		template = data[0];
		view = data[1];

		response.writeData( Mustache.render( template, view ) );
	} else {
		response.setStatusCode( 403 );
		view = { app_init_js: request.appInitScript };
		response.writeData( Mustache.render( template, view ) );
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

var post = function( passThrough ) {
	if ( request.method === 'POST' ) {
		passThrough( );
	}
};

var get = function( passThrough ) {
	if ( request.method === 'GET' ) {
		passThrough( );
	}
};
