include "cRunner.js"
include "diff_match_patch.js"
include "diff_creole.js"

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

if activityData.numCFiles
	for i in [0...(activityData.numCFiles)]
		file = JSON.parse activityData['CFile' + i]
		files[file.name] = file.data

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
		programStdin = (activityData.stdin.replace '\r', '')
		programStdout = ''
		programStderr = ''
		environment =
			stdin: -> programStdin
			stdout: (output) -> programStdout += output + '\n'
			stderr: (error) -> programStderr += error + '\n'

		# parse commandline arguments into a list
		args = (arg.replace(/^\"|\"$/g, '') for arg in activityData.args.match(/\w+|"[^"]+"/g))

		# run the program
		CRunner.runProgram compiledCode, environment, args

		# remove \r characters from provided stdout
		expectedOut = (activityData.stdout.replace '\r', '')
		expectedReturnValue = parseInt activityData.returnValue

		if activityData.isStdoutStripped
			programStdout = programStdout.replace(/\n/g , '')
			expectedOut = expectedOut.replace(/\n/g, '')

		if (programStdout is expectedOut) and (environment.returnValue is expectedReturnValue)
			# matches, woohoo!
			correctComment = activityData.correctComment
			if !correctComment
				correctComment = "Correct!"

			markObject = { completed: true, comments: correctComment }
		else

			incorrectComment = activityData.incorrectComment
			
			if !incorrectComment
				incorrectComment = "Incorrect."

			incorrectComment = incorrectComment.replace /\[\[\s*stdin\s*\]\]/g, programStdin
			incorrectComment = incorrectComment.replace /\[\[\s*stdout\s*\]\]/g, programStdout
			incorrectComment = incorrectComment.replace /\[\[\s*stderr\s*\]\]/g, programStderr


			incorrectComment = incorrectComment.replace /\[\[\s*exitCode\s*\]\]/g, environment.returnValue

			incorrectComment = incorrectComment.replace /\[\[\s*expectedStdout\s*\]\]/g, expectedOut
			incorrectComment = incorrectComment.replace /\[\[\s*expectedExitCode\s*\]\]/g, (''+expectedReturnValue)

			if (incorrectComment.match /\[\[\s*stdoutDiff\s*\]\]/g)
				dmp = new diff_match_patch()
				dmp.Diff_Timeout = 1.0

				diff = dmp.diff_main programStdout, programStderr
				dmp.diff_cleanupSemantic diff
				creole = dmp.diff_prettyCreole diff

				incorrectComment = incorrectComment.replace /\[\[\s*stdoutDiff\s*\]\]/g, creole

			# better luck next time
			markObject = { completed: false, comments: incorrectComment }

# bundle this mark into a marks update object
marks = {}
marks[data.user] = markObject

# save marks on openlearning
OpenLearning.activity.setMarks marks
