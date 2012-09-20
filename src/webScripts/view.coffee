include "mustache.js"
include "guards.js"

template = include "viewTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

setDefaults = (view) ->
	view.codemirror_js = mediaURL 'codemirror.js'
	view.codemirror_mode_js = mediaURL 'clike.js'
	view.codemirror_css = mediaURL 'codemirror.css'

# POST and GET controllers
post = ->
	# grab data from POST
	view =
		fileData: request.data.fileData

	file =
		filename: 'solution.c'
		data: view.fileData

	submission =
		file: file

	# set submission data
	try
		submissionData = OpenLearning.activity.saveSubmission request.user, submission, 'file'
		view.url = submissionData.url
	catch err
		view.error = 'Something went wrong: Unable to save data'

	setDefaults view

	view.message = "Saved"

	return view

get = ->
	view = {}

	# get activity page data
	try
		submissionPage = (OpenLearning.activity.getSubmission request.user)
	catch err
		view.error = 'Something went wrong: Unable to load submission'

	if !view.error
		submission = submissionPage.submission
		if submission.file
			view.fileData = submission.file.data
			view.url = submissionPage.url

		try
			view.isSubmitted = (OpenLearning.activity.isSubmitted request.user)
		catch err
			if !view.error
				view.error = 'Something went wrong: '
			view.error += 'Unable to load submitted status '

		try
			marks = (OpenLearning.activity.getLatestMark request.user)
		catch err
			if !view.error
				view.error = 'Something went wrong: '
			view.error += 'Unable to load marks ' + JSON.stringify(err)

		if marks
			view.comments = marks.comments

		if marks and marks.completed
			view.completed = true
			view.message = "You have completed this activity"
		else
			view.completed = false
			if view.isSubmitted
				# or it is wrong?
				view.message = "Your submission is awaiting Auto-marking"

	setDefaults view

	return view


checkPermission 'read', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

