include "mustache.js"
include "guards.js"

template = include "adminTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"

fields = ['stdin', 'stdout', 'args', 'returnValue', 'correctComment', 'incorrectComment', 'replaceFrom', 'replaceTo']
booleanFields = ['isInline', 'isStdoutStripped', 'ignoreStdout', 'ignoreExitCode', 'usesReplace']

setDefaults = (view) ->
	if not view.incorrectComment
		view.incorrectComment = '''
Your program produced:

{{{
<<stdout>>
}}}

----

Expecting:

{{{
<<expectedStdout>>
}}}
'''	
	
	if not view.returnValue? or view.returnValue is ''
		view.returnValue = '0'

# POST and GET controllers
post = ->
	# grab data from POST
	view = {}

	# this app is automarked
	view.isAutomarked = true

	for field in fields
		view[field] = request.data[field]

	for field in booleanFields
		if request.data[field] is 'yes'
			view[field] = true
		else
			view[field] = false


	if view.isInline
		OpenLearning.activity.setSubmissionType 'file'
	else
		OpenLearning.activity.setSubmissionType 'multi-file'


	# this app is embedded if the inline was checked
	view.isEmbedded = view.isInline

	# set activity page data
	try
		view.url = (OpenLearning.page.setData view, request.user).url
	catch err
		view.error = 'Something went wrong: Unable to save data'

	view.message = 'Saved'
	return view

get = ->
	view = {}

	# get activity page data
	try
		page = OpenLearning.page.getData( request.user )
		data = page.data
		view.url = page.url
	catch err
		view.error = 'Something went wrong: Unable to load data'
	
	if not view.error?
		# build view from page data
		for field in fields
			view[field] = data[field]
		
		for field in booleanFields
			view[field] = data[field]

	return view


checkPermission 'write', accessDeniedTemplate, ->
	view = {}
	if request.method is 'POST'
		view = post()
	else
		view = get()

	setDefaults view

	render template, view

