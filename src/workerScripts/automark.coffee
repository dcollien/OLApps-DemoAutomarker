user = data.user
submission = data.submission

expectedContent = OpenLearning.getPageData( ).match

marks = {}

if submission is expectedContent
	marks[user] = { pending: false, completed: true }
else
	marks[user] = { pending: false, completed: false }

OpenLearning.activities.setMarks marks
