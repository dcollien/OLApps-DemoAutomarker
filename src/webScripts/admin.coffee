include "mustache.js"

# Guards
adminOnly = (passThrough) ->
	if request.isAdmin
		passThrough()
	else
		response.setStatusCode 403
		response.writeText 'Error: Not Allowed'

post = (passThrough) -> passThrough() if request.method is 'POST'
get  = (passThrough) -> passThrough() if request.method is 'GET'


# View Creation
template = include "adminTemplate.html"

adminOnly ->
	view = 
		app_init_js: request.appInitScript
		csrf_token:  request.csrfFormInput

	post ->
		view['match'] = request.data['match']
		OpenLearning.page.setData view, request.user

	get ->
		view['match'] = OpenLearning.page.getData( request.user )['match']
	
	response.writeData Mustache.render( template, view )
