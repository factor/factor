USING: system tools.test ;
IN: magic

{ "data" } [ image guess-file ] unit-test
{ "application/octet-stream" } [ image guess-mime-type ] unit-test
{ "binary" } [ image guess-mime-encoding ] unit-test
