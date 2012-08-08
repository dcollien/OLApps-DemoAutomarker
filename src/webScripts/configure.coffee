include "mustache.js"
include "guards.js"

# View Creation
template = include "adminTemplate.html"
deniedTemplate = include "accessDeniedTemplate.html"

adminOnly deniedTemplate, ->
	view = {}

	post ->
		view['stdin']  = request.data['stdin']
		view['stdout'] = request.data['stdout']
		view['args']   = request.data['args']

		OpenLearning.page.setData view, request.user

	get ->
		data = OpenLearning.page.getData( request.user )

		view['stdin']  = data['stdin']
		view['stdout'] = data['stdout']
		view['args']   = data['args']

	view['app_init_js'] = request.appInitScript
	view['csrf_token']  = request.csrfFormInput

	return [template, view]
