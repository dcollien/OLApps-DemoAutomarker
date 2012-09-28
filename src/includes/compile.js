include("cCompiler.js");

var compileSubmission;

compileSubmission = function(data, shouldSave) {
  var activityData, compiledCode, error, file, files, submission, submissionData, i, fileList;

  try {
    activityData = OpenLearning.page.getData().data;
    submissionData = OpenLearning.activity.getSubmission(data.user);
  } catch (err) {
    log(err);
    return null;
  }

  try {
    markingCodePage = OpenLearning.page.readSubpage('MarkingCode');
  } catch (err) {
    markingCodePage = null;
  }
  
  files = {};
  error = null;
  submission = {};

  if (submissionData.submission.files) {
    submission.files = submissionData.submission.files;
    fileList = submissionData.submission.files;
    for (i = 0; i < fileList.length; i++) {
      file = fileList[i];
      files[file.filename] = file.data;
    }
  } else if (submissionData.submission.file) {
    submission.file = submissionData.submission.file;
    file = submissionData.submission.file;
    files[file.filename] = file.data;
  } else {
    error = 'No files in submission';
    files = null;
  }

  if (files !== null && markingCodePage !== null && markingCodePage.files) {
    fileList = markingCodePage.files;
    for (i = 0; i < fileList.length; i++) {
      file = fileList[i];
      files[file.filename] = file.data;
    }
  }

  if (files !== null) {
    compiledCode = CRunner.compileFiles(files);
    if (compiledCode.error) {
      error = compiledCode.response;
    }
  }

  submission.metadata = {
    compileError: error,
    compiled: true,
    compiledCode: compiledCode
  };
  
  if (shouldSave) {
    OpenLearning.activity.saveSubmission(data.user, submission, 'file');
  }

  return {
    error: error,
    compiledCode: compiledCode,
    activityData: activityData
  };
};
