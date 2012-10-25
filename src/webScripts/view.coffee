include "mustache.js"
include "guards.js"

template = include "viewTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

setDefaults = (view) ->
	view.codemirror_js = mediaURL 'codemirror.js'
	view.codemirror_mode_js = mediaURL 'clike.js'
	view.codemirror_css = mediaURL 'codemirror.css'
	view.loader_gif = mediaURL 'loader.gif'

# POST and GET controllers
post = ->
	# grab data from POST

	# saving as draft
	view =
		fileData: request.data.fileData

	file =
		filename: 'solution.c'
		data: view.fileData

	submission =
		file: file
		metadata: {
			compiled: false
			draft: true
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
		view.submissionPage = submissionPage
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
			view.isDraft = submission.metadata.draft
			view.pending = submission.metadata.pending
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

		view.feedbackHeader = "Feedback:"
		view.feedbackClass = "feedback"

		if (view.compileError)
			view.messageHeader = "Compile Error"
			view.message = "Unable to compile your program. Check the compile errors below."
			view.alertClass = "alert-error alert-block"
			view.feedbackHeader = "Compile Errors:"
			view.feedbackClass = "redFeedback"
		else if (view.isCorrect is false)
			view.messageHeader = "Did Not Pass Tests"
			view.message = "Your program didn't pass the tests. Check the feedback below."
			view.alertClass = "alert-error alert-block"
			view.feedbackHeader = "Testing Output:"
		else if view.status is 'incomplete' or view.isDraft
			view.messageHeader = "Submit a Solution"
			view.message = "Write your solution below:"
			view.alertClass = "alert-info"
			view.feedbackHeader = "Feedback from your last submission:"
			view.incomplete = true
		else if view.pending or (view.status is 'pending')
			view.messageHeader = "Submitted and Awaiting Testing"
			view.message = "Your program has been submitted and is awaiting compilation and testing."
			view.alertClass = "alert-info"
			view.pending = true
			view.comments = false
		else if view.status is 'completed'
			view.messageHeader = "Correct"
			view.message = "You have completed this task."
			view.alertClass = "alert-success"
		
		if view.status is 'completed'	
			view.completed = true

	setDefaults view

	return view


checkPermission 'read', accessDeniedTemplate, ->
	if request.method is 'POST' and request.data.action == 'saveProgram'
		render template, post()
	else
		render template, get()

