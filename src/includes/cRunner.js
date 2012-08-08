function encodeFieldPart(boundary,name,value) {
  var return_part = "--" + boundary + "\r\n";
  return_part += "Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n";
  return_part += "Content-Type: text/plain; charset=utf-8\r\n\r\n";
  return_part += value + "\r\n";
  return return_part;
}

function encodeFilePart(boundary,type,name,filename) {
  var return_part = "--" + boundary + "\r\n";
  return_part += "Content-Disposition: form-data; name=\"" + name + "\"; filename=\"" + filename + "\"\r\n";
  return_part += "Content-Type: " + type + "\r\n\r\n";
  return return_part;
}

var CRunner = {
  compileFiles: function( files ) {
    var options = {
      url: 'http://compile.openlearningapps.net/application/compile',
      headers: {}
    };
    
    var boundary = 'FILEBOUNDARY' + (Math.floor (Math.random() * 999999999999));
    var post_data = '';
    post_data += encodeFieldPart( boundary, 'privateKey', 'openlearningisthebestever' );
    
    for ( var filename in files ) {
      if ( files.hasOwnProperty( filename ) ) {
        var code = files[filename];
        
        post_data += encodeFilePart( boundary, 'text/plain; charset=utf-8', filename, filename );
        post_data += code + '\r\n';
      }
    }
    
    post_data += "--" + boundary + "--";
    
    options.headers['Content-Type'] = 'multipart/form-data; boundary=' + boundary;
    options.headers['Content-Length'] = post_data.length;

    try {
      return openURL( options.url, options.headers, post_data );
    } catch (err) {
      return err;
    }
  },

  runProgram: function( compiledCode, environment, args ) {
    try {
      var process = undefined;
      var importScripts = undefined;
      var window = undefined;
    
      eval( compiledCode );
      var module = getModule( environment );
      module.run( args );
      return true;
    } catch (err) {
      return err;
    }
  }
};

