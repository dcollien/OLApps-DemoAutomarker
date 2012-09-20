include "mustache.js"
include "guards.js"

template = include "adminTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

fields = ['stdin', 'stdout', 'args', 'returnValue', 'correctComment', 'incorrectComment']

setDefaults = (view) ->
	if not view.args? or view.args is ''
		view.args = 'myProgram'

	if not view.returnValue? or view.returnValue is ''
		view.returnValue = '0'

	view.cFiles = []
	for i in [0...view.numCFiles]
		file = JSON.parse data['CFile' + i]
		file.index = i
		view.cFiles.push file


# POST and GET controllers
post = ->
	# grab data from POST
	view = {}

	for field in fields
		view[field] = request.data[field]

	view.numCFiles = parseInt request.data.numCFiles
	for i in [0...view.numCFiles]
		view['CFile' + i] = JSON.stringify({
				name: request.data['CFileName' + i]
				data: request.data['CFileData' + i]
			})


	if request.data.isEmbedded is 'yes'
		OpenLearning.activity.setSubmissionType 'file'
		view.isEmbedded = true
	else
		OpenLearning.activity.setSubmissionType 'multi-file'
		view.isEmbedded = false

	if request.data.isStdoutStripped is 'yes'
		view.isStdoutStripped = true
	else
		view.isStdoutStripped = false

	if request.data.commentExpectedOutput is 'yes'
		view.commentExpectedOutput = true
	else
		view.commentExpectedOutput = false

	# set activity page data
	try
		OpenLearning.page.setData view, request.user
	catch err
		view.error = 'Something went wrong: Unable to save data'

	setDefaults view

	view.message = 'Saved'
	return view

get = ->
	view = {}

	# get activity page data
	try
		data = OpenLearning.page.getData( request.user )
	catch err
		view.error = 'Something went wrong: Unable to load data'
	
	if not view.error?
		# build view from page data
		for field in fields
			view[field] = data[field]

	if data.isEmbedded
		view.isEmbedded = true

	if data.commentExpectedOutput
		view.commentExpectedOutput = true

	setDefaults view

	return view


checkPermission 'write', accessDeniedTemplate, ->
	if request.method is 'POST'
		render template, post()
	else
		render template, get()

