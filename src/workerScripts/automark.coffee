include "cRunner.js"

activityData = OpenLearning.page.getData( )

files = {}
for file in data.submission
	files[file.filename] = file.data

compiledCode = CRunner.compileFiles files

programStdout = ''
environment =
	stdin: -> (activityData.stdin.replace '\r', '')
	stdout: (output) -> programStdout += output + '\n'

args = ['run', activityData.args] # TODO: arg parsing

CRunner.runProgram compiledCode, environment, args

marks = {}
if programStdout is (activityData.stdout.replace '\r', '')
	marks[data.user] = { completed: true }
else
	marks[data.user] = { completed: false }

OpenLearning.activity.setMarks marks
