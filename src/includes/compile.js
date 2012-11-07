include("cCompiler.js");

var compileSubmission, doReplace;


doReplace = function(data, replaceFrom, replaceTo) {
  if (replaceFrom) {
    data = data.replace(new RegExp(replaceFrom), replaceTo);
  }

  return data;
};

compileSubmission = function(data, shouldSave) {
  var activityData, compiledCode, error, file, files, submission, submissionData;
  var i, fileList, replaceFrom, replaceTo;

  try {
    activityData = OpenLearning.page.getData().data;
    submissionData = OpenLearning.activity.getSubmission(data.user);
  } catch (err) {
    log(err);
    return null;
  }

  if (activityData.usesReplace) {
    replaceFrom = activityData.replaceFrom;
    replaceTo = activityData.replaceTo;
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
      files[file.filename] = doReplace(file.data, replaceFrom, replaceTo);
    }
  } else if (submissionData.submission.file) {
    submission.file = submissionData.submission.file;
    file = submissionData.submission.file;
    files[file.filename] = doReplace(file.data, replaceFrom, replaceTo);
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
