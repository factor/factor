USING: tools.test ;
IN: cocoa.apple-script

{ "\"\\\\\"" } [ "\\" quote-apple-script ] unit-test
{ "\"hello\\nthere\"" } [ "hello
there" quote-apple-script ] unit-test ! no space, just a newline
{ "\"hello\\rthere\"" } [ "hello\rthere" quote-apple-script ] unit-test
{ "\"hello\\tthere\"" } [ "hello\tthere" quote-apple-script ] unit-test
{ "\"hello\\tthere\"" } [ "hello	there" quote-apple-script ] unit-test ! actual tab character 0x09

