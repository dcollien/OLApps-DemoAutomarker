include "mustache.js"
include "guards.js"

# View Creation
template = include "adminTemplate.html"
deniedTemplate = include "accessDeniedTemplate.html"

adminOnly deniedTemplate, ->
	view = {}

	if request.method is 'POST'
		# grab data from post data
		view.stdin  = request.data.stdin
		view.stdout = request.data.stdout
		view.args   = request.data.args

		# set activity page data
		try
			OpenLearning.page.setData view, request.user
		catch err
			view.error = 'Unable to connect to OpenLearning'

	else
		# get activity page data
		try
			data = OpenLearning.page.getData( request.user )
		catch err
			view.error = 'Unable to connect to OpenLearning'

		# build view from page data
		view.stdin  = data.stdin
		view.stdout = data.stdout
		view.args   = data.args

	# add on extra template data
	view.app_init_js = request.appInitScript
	view.csrf_token  = request.csrfFormInput

	return [template, view]
