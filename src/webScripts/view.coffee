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
		metadata: {
			compiled: false
		}

	# set submission data
	try
		submissionData = OpenLearning.activity.saveSubmission request.user, submission, 'file'
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
		view.error = 'Something went wrong: Unable to load submission. '

	if !view.error
		submission = submissionPage.submission
		if submission.file
			view.fileData = submission.file.data
			view.url = submissionPage.url

		if submission.metadata
			view.compiled = submission.metadata.compiled
			view.compileError = submission.metadata.compileError
			view.isCorrect = submission.metadata.isCorrect
		try
			view.status = (OpenLearning.activity.getStatus request.user)
		catch err
			if !view.error
				view.error = 'Something went wrong: '
			view.error += 'Unable to load submitted status. '

		try
			mark = (OpenLearning.activity.getLatestMark request.user)
		catch err
			if !view.error
				view.error = 'Something went wrong: '
			view.error += 'Unable to load marking information. '

		if mark
			view.comments = mark.comments

		if (view.compileError)
			view.messageHeader = "Compile Error"
			view.message = "There was a problem compiling your program."
			view.alertClass = "alert-error alert-block"
		else if (view.isCorrect is false)
			view.messageHeader = "Problem in Testing"
			view.message = "There was a problem running your program."
			view.alertClass = "alert-block"
		else if view.status is 'incomplete'
			view.messageHeader = "Submit a Solution"
			view.message = "Write your solution below:"
			view.alertClass = "alert-info"
			view.incomplete = true
		else if view.status is 'pending'
			view.messageHeader = "Awaiting Testing"
			view.message = "Your program is awaiting compilation and testing."
			view.alertClass = "alert-info"
			view.pending = true
			view.comments = false
		else if view.status is 'completed'
			view.messageHeader = "Completed"
			view.message = "You have completed this task."
			view.alertClass = "alert-success"
		
		if view.status is 'completed'	
			view.completed = true

	setDefaults view

	return view


checkPermission 'read', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

