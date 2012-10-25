include "compile.js"
include "diff_match_patch.js"
include "diff_creole.js"

compilation = compileSubmission data

submission = {}
submission.metadata =
	compiled: true
	pending: false

if compilation is null or compilation.error
	# there was a compile error
	comments = '\n{{{\n'
	comments += if compilation then compilation.error else 'Compiler Error'
	comments += '\n}}}\n'

	markObject = { completed: false, comments: comments }
	
	submission.metadata.compileError = true
else
	activityData = compilation.activityData

	# collect stdout and provide stdin
	programStdin = (activityData.stdin.replace '\r', '')
	
	args = []
	if activityData.args
		# parse commandline arguments into a list
		args = (arg.replace(/^\"|\"$/g, '') for arg in activityData.args.match(/\w+|"[^"]+"/g))

	environment =
		args: args
		stdin: programStdin
		init: (fs) ->
			#create readable, non-writable file
			#fs.createDataFile('/', 'foo', 'abc', true, false)
			#create readable, writable file
			#fs.createDataFile('/', 'bar', '', true, true)

	# run the program

	context = null

	try
		output = ((compiledCode, environment) ->
			eval( compiledCode )
			return Program(environment).run()
		).call context, compilation.compiledCode, environment
	catch err
		output =
			stdout: ''
			stderr : err
			files: {}

	# remove \r characters from provided stdout
	expectedOut = (activityData.stdout.replace '\r', '')
	expectedReturnValue = parseInt activityData.returnValue

	if activityData.isStdoutStripped
		programStdout = output.stdout.replace('\n' , '')
		expectedOut = expectedOut.replace('\n', '')
	else
		programStdout = output.stdout

	programStderr = (output.stderr.replace '\r', '')

	isCorrect = true

	if not activityData.ignoreStdout
		isCorrect = isCorrect and (programStdout is expectedOut)

	if not activityData.ignoreExitCode
		isCorrect = isCorrect and (output.exitCode is expectedReturnValue)
	
	markup = ''
	if isCorrect
		# matches, woohoo!
		correctComment = activityData.correctComment
		if !correctComment
			correctComment = "Correct!"

		correctComment = correctComment.replace /<<\s*stdin\s*>>/g, programStdin
		correctComment = correctComment.replace /<<\s*stdout\s*>>/g, programStdout
		correctComment = correctComment.replace /<<\s*stderr\s*>>/g, programStderr

		correctComment = correctComment.replace /<<\s*exitCode\s*>>/g, output.exitCode

		markObject = { completed: true, comments: correctComment }

		submission.metadata.isCorrect = true

		markup = '{{{\n#!code\n' + programStdout + '\n}}}'
	else
		incorrectComment = activityData.incorrectComment

		if !incorrectComment
			incorrectComment = "Incorrect."

		incorrectComment = incorrectComment.replace /<<\s*stdin\s*>>/g, programStdin
		incorrectComment = incorrectComment.replace /<<\s*stdout\s*>>/g, programStdout
		incorrectComment = incorrectComment.replace /<<\s*stderr\s*>>/g, programStderr


		incorrectComment = incorrectComment.replace /<<\s*exitCode\s*>>/g, output.exitCode

		incorrectComment = incorrectComment.replace /<<\s*expectedStdout\s*>>/g, activityData.stdout
		incorrectComment = incorrectComment.replace /<<\s*expectedExitCode\s*>>/g, (''+expectedReturnValue)

		if (incorrectComment.match /<<\s*stdoutDiff\s*>>/g)
			dmp = new diff_match_patch()
			dmp.Diff_Timeout = 1.0

			diff = dmp.diff_main programStdout, programStderr
			dmp.diff_cleanupSemantic diff
			creole = dmp.diff_prettyCreole diff

			incorrectComment = incorrectComment.replace /<<\s*stdoutDiff\s*>>/g, creole

		# better luck next time
		markObject = { completed: false, comments: incorrectComment }

		submission.metadata.isCorrect = false

submission.markup = markup

OpenLearning.activity.saveSubmission(data.user, submission, 'file')

# bundle this mark into a marks update object
marks = {}
marks[data.user] = markObject

# save marks on openlearning
OpenLearning.activity.setMarks marks

