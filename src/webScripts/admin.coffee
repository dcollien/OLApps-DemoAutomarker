include "mustache.js"
template = include "adminTemplate.html"

# Logic Filters
adminOnly = (passThrough) ->
	if OpenLearning.isAdmin request.user
		passThrough()
	else
		response.setStatusCode 403
		response.writeText 'Error: Not Allowed'

post = (passThrough) -> passThrough() if request.method is 'POST'
get  = (passThrough) -> passThrough() if request.method is 'GET'

adminOnly ->
	view = 
		app_init_js: request.appInitScript
		csrf_token:  request.csrfFormInput

	post ->
		view = { 'match': request.data['match'] }
		OpenLearning.setPageData view

	get ->
		view = { 'match': OpenLearning.getPageData( )['match'] }
	
	response.writeData Mustache.render( template, view )
