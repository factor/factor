USING: magic system tools.test ;
IN: magic.tests

{ "data" } [ image-path guess-file ] unit-test
{ "application/octet-stream" } [ image-path guess-mime-type ] unit-test
{ "binary" } [ image-path guess-mime-encoding ] unit-test
