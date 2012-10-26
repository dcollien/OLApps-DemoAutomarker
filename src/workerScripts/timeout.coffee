if data.parentTarget is 'automark'
	submission = {}
	submission.metadata =
		compiled: true
		pending: false
		isCorrect: false
		markup: 'Program timed out.'

	OpenLearning.activity.saveSubmission(data.parentData.user, submission, 'file')
	markObject = { completed: false, comments: '**Execution timed out**: the program ran for too long and was stopped.' }

	# bundle this mark into a marks update object
	marks = {}
	marks[data.parentData.user] = markObject

	# save marks on openlearning
	OpenLearning.activity.setMarks marks
