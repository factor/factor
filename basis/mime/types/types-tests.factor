USING: io.encodings.utf8 mime.types tools.test ;

{ "application/postscript" } [ "foo.ps" mime-type ] unit-test
{ "application/octet-stream" } [ "foo.ps.gz" mime-type ] unit-test
{ "text/plain" } [ "foo.factor" mime-type ] unit-test
{ "zip" } [ "application/zip" mime-type>extension ] unit-test

{ utf8 } [ "text/json" mime-type-encoding ] unit-test
{ utf8 } [ "text/plain" mime-type-encoding ] unit-test
{ utf8 } [ "application/json" mime-type-encoding ] unit-test