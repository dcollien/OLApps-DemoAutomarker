// http://onteria.wordpress.com/2011/05/30/multipartform-data-uploads-using-node-js-and-http-request/
function encodeFieldPart(boundary,name,value) {
  var return_part = "--" + boundary + "\r\n";
  return_part += "Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n";
  return_part += value + "\r\n";
  return return_part;
}

function encodeFilePart(boundary,type,name,filename) {
  var return_part = "--" + boundary + "\r\n";
  return_part += "Content-Disposition: form-data; name=\"" + name + "\"; filename=\"" + filename + "\"\r\n";
  return_part += "Content-Type: " + type + "\r\n\r\n";
  return return_part;
}

var compileFiles = function( files ) {
  var options = {
    url: 'http://compile.openlearningapps.net/application/compile',
    headers: {}
  };
  
  var boundary = Math.random();
  var post_data = '';
  //post_data += encodeFieldPart( boundary, 'privateKey', 'openlearningisthebestever' );
  
  for ( var filename in files ) {
    if ( files.hasOwnProperty( filename ) ) {
      var code = files[filename];
      
      post_data += encodeFilePart( boundary, 'text/plain', filename, filename );
      post_data += code;
    }
  }
  
  options.headers['Content-type'] = 'multipart/form-data; boundary=' + boundary;
  options.headers['Content-length'] = post_data.length;

  return openURL( options.url, options.headers, post_data );
};

var files = {};
var lastSubmission = JSON.parse(retrieveData( 'data', ['lastSubmission'] )['lastSubmission']);

response.writeJSON( lastSubmission );

response.writeData('<br/>');

var submission = lastSubmission.submission;
response.writeJSON( submission );

response.writeData('<br/>');

for ( var i in submission ) {
  var file = submission[i];
  files[file.filename] = file.data;
}

response.writeJSON( files );

response.writeData('<br/>');

var compilerResponse = compileFiles( files );
response.writeJSON( compilerResponse );


