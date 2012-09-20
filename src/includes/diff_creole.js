diff_match_patch.prototype.diff_prettyCreole = function(diffs) {
  var creole = [];
  var pattern_para = /\n/g;
  
  for (var x = 0; x < diffs.length; x++) {
    var op = diffs[x][0];    // Operation (insert, delete, equal)
    var data = diffs[x][1];  // Text of change.
    var text = data.replace(pattern_para, '\\\\');
    switch (op) {
      case DIFF_INSERT:
        creole[x] = '**' + text + '**';
        break;
      case DIFF_DELETE:
        creole[x] = '[-' + text + '-]';
        break;
      case DIFF_EQUAL:
        creole[x] = text;
        break;
    }
  }
  return creole.join('');
};
