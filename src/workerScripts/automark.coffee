include "cRunner.js"

# get activity app data from openlearning
activityData = OpenLearning.page.getData( )

markObject = {}
files = {}

# check if a single file upload, or multiple files
# and build the "files" object
if (data.submission instanceof Array)
	# multiple files
	for file in data.submission
		files[file.filename] = file.data
else
	# single file
	file = data.submission.file
	files[file.filename] = file.data

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

	if (programStdout is expectedOut)
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
