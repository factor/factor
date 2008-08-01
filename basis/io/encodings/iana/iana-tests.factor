USING: io.encodings.iana io.encodings.ascii tools.test ;

[ ascii ] [ "US-ASCII" name>encoding ] unit-test
[ ascii ] [ "ASCII" name>encoding ] unit-test
[ "US-ASCII" ] [ ascii encoding>name ] unit-test
