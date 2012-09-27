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
	# grab data from POST
	view =
		fileData: request.data.fileData

	file =
		filename: 'solution.c'
		data: view.fileData

	submission =
		file: file
		metadata: {
			submitted: true
		}

	# set submission data
	try
		submissionData = OpenLearning.activity.saveSubmission request.user, submission, 'file'
		view.url = submissionData.url
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

	status = (OpenLearning.activity.getStatus request.user)

	if status is 'incomplete' or status is 'pending'
		view.message = "Your program has been submitted and will be auto-marked soon"
	else
		view.message = "Automarking Completed"
	
	return view


checkPermission 'read', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

