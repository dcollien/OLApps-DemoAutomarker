view = {}

# get activity page data
try
	submissionPage = (OpenLearning.activity.getSubmission request.user)
catch err
	view.error = 'Something went wrong: Unable to load submission. '

if !view.error
	submission = submissionPage.submission

	if submission.metadata
		view.compiled = submission.metadata.compiled
		view.compileError = submission.metadata.compileError
		view.isCorrect = submission.metadata.isCorrect
		view.isDraft = submission.metadata.draft
		view.pending = submission.metadata.pending

response.setHeader 'Content-Type', 'application/json'
response.writeJSON view
