include "mustache.js"
include "guards.js"

template = include "submitTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

setDefaults = (view) ->
	view.codemirror_js = mediaURL 'codemirror.js'
	view.codemirror_mode_js = mediaURL 'clike.js'
	view.codemirror_css = mediaURL 'codemirror.css'

	# get activity page data
	try
		submissionPage = (OpenLearning.activity.getSubmission request.user)
		submission = submissionPage.submission
		if submission.file
			view.fileData = submission.file.data
			view.url = submissionPage.url
	catch err
		view.error = 'Something went wrong: Unable to load data: ' + err

# POST and GET controllers
post = ->
	view = {}
	# submit
	try
		submitSuccess = OpenLearning.activity.submit request.user
	catch err
		view.error = 'Something went wrong: Unable to save data'

	setDefaults view

	if not view.error
		view.message = "Submitted for Automarking"

	return view

get = ->
	view = {}

	setDefaults view

	marks = (OpenLearning.activity.getMarks [request.user])[request.user]

	if marks and marks.completed
		view.message = "Automarking Completed"
	else
		view.message = "Waiting for Automarking"

	return view


checkPermission 'read', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

