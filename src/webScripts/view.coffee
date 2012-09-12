include "mustache.js"
include "guards.js"

template = include "viewTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"


# POST and GET controllers
post = ->
	# grab data from POST
	view =
		fileData: request.data.fileData

	file =
		filename: 'solution.c'
		data: view.fileData

	# set submission data
	try
		OpenLearning.activity.saveSubmission request.user, file, 'file'
	catch err
		view.error = 'Something went wrong: Unable to save data'
	
	return view

get = ->
	view = {}

	# get activity page data
	try
		view.fileData = (OpenLearning.activity.getSubmission request.user).data
	catch err
		view.error = 'Something went wrong: Unable to load data: ' + err

	return view


checkPermission 'write', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

