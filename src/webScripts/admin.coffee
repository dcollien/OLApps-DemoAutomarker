include "mustache.js"
template = include "adminTemplate.html"

adminOnly = (callback) ->
	if OpenLearning.isAdmin request.user
		callback()
	else
		response.setStatusCode 403
		response.writeText 'Error: Not Allowed'

post = ->
	data = { 'match': request.data['match'] }
	OpenLearning.setPageData data
	return data

get = -> { 'match': OpenLearning.getPageData( )['match'] }


adminOnly ->
	view = if request.method is 'POST' then post() else get()

	view['app_init_js'] = request.appInitScript
	view['csrf_token']  = request.csrfFormInput
	
	response.writeData Mustache.render( template, view )


