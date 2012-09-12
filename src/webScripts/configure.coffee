include "mustache.js"
include "guards.js"

template = include "adminTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

fields = ['stdin', 'stdout', 'args', 'isEmbedded']

# POST and GET controllers
post = ->
	# grab data from POST
	view = {}

	for field in fields
		view[field] = request.data[field]

	# set activity page data
	try
		OpenLearning.page.setData view, request.user
	catch err
		view.error = 'Something went wrong: Unable to save data'

	if not view.args? or view.args is ''
		view.args = 'run'
	
	return view

get = ->
	view = {}

	# get activity page data
	try
		data = OpenLearning.page.getData( request.user )
	catch err
		view.error = 'Something went wrong: Unable to load data'
	
	if not view.error?
		# build view from page data
		for field in fields
			view[field] = data[field]

	return view


checkPermission 'write', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

