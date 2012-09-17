include "cRunner.js"

# get activity app data from openlearning
activityData = OpenLearning.page.getData( )

markObject = {}
files = {}

# check if a single file upload, or multiple files
# and build the "files" object
if data.submission.files
	# multiple files
	for file in data.submission.files
		files[file.filename] = file.data
else if data.submission.file
	# single file
	file = data.submission.file
	files[file.filename] = file.data
else
	# not compilable
	markObject = { completed: false, comments: 'No files in submission' }
	files = null

if files isnt null
	# compile the files
	compiledCode = CRunner.compileFiles files

	if compiledCode.error
		# there was a compile error
		comments = '{{{\n'
		comments += compiledCode.response
		comments += '}}}\n'
		markObject = { completed: false, comments: comments }
	else
		# collect stdout and provide stdin
		programStdout = ''
		environment =
			stdin: -> (activityData.stdin.replace '\r', '')
			stdout: (output) -> programStdout += output + '\n'

		# parse commandline arguments into a list
		args = (arg.replace(/^\"|\"$/g, '') for arg in activityData.args.match(/\w+|"[^"]+"/g))

		# run the program
		CRunner.runProgram compiledCode, environment, args

		# remove \r characters from provided stdout
		expectedOut = (activityData.stdout.replace '\r', '')
		expectedReturnValue = parseInt activityData.returnValue

		if (programStdout is expectedOut) and (environment.returnValue is expectedReturnValue)
			# matches, woohoo!
			markObject = { completed: true, comments: '**You are Awesome!**' }
		else
			# better luck next time
			comments = '{{{\n'
			comments += 'Expected: ' + JSON.stringify( expectedOut ) + '\n'
			comments += 'Program output: ' + JSON.stringify( programStdout ) + '\n' 
			comments += '}}}\n'

			markObject = { completed: false, comments: comments }

# bundle this mark into a marks update object
marks = {}
marks[data.user] = markObject

# save marks on openlearning
OpenLearning.activity.setMarks marks
