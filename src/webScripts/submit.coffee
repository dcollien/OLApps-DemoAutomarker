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
			compiled: false
			submitted: true
			pending: true
			draft: false
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
		view.message = "Your program has been submitted for auto-marking. Check back again soon for your results."

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



response.setHeader 'Content-Type', 'application/json'

if (not request.sessionData?) or (not request.sessionData.permissions?)
	view = {
		error: "No Session Data"
	}
else if "read" in request.sessionData.permissions
	if (request.method is 'POST') and (request.data.action is 'submit')
		view = post()
	else
		view = get()
else
	view = {
		error: "Permission Denied"
	}

response.writeJSON view


