include "mustache.js"
include "guards.js"

template = include "adminTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

fields = ['stdin', 'stdout', 'args']

# POST and GET controllers
post = ->
	# grab data from POST
	view = {}

	for field in fields
		view[field] = request.data[field]


	if request.data.isEmbedded is 'yes'
		OpenLearning.activity.setSubmissionType 'file'
		view.isEmbedded = true
	else
		OpenLearning.activity.setSubmissionType 'multi-file'
		view.isEmbedded = false

	# set activity page data
	try
		OpenLearning.page.setData view, request.user
	catch err
		view.error = 'Something went wrong: Unable to save data'

	if not view.args? or view.args is ''
		view.args = 'run'

	view.message = 'Saved'
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

	if data.isEmbedded
		view.isEmbedded = true

	return view


checkPermission 'write', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

