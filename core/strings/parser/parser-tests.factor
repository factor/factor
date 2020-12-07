USING: accessors eval kernel lexer strings.parser tools.test ;

{ "Hello\n\rworld" } [ "Hello\\n\\rworld" unescape-string ] unit-test

{ "Hello\n\rworld" } [ "Hello\n\rworld" ] unit-test
{ "Hello\n\rworld\n" } [ "Hello\n\rworld
" ] unit-test
{ "Hello\n\rworld" "hi" } [ "Hello\n\rworld" "hi" ] unit-test
{ "Hello\n\rworld" "hi" } [ "Hello\n\rworld" "hi" ] unit-test
{ "Hello\n\rworld\n" "hi" } [ "Hello\n\rworld
" "hi" ] unit-test
{ "Hello\n\rworld\"" "hi" } [ "Hello\n\rworld\"" "hi" ] unit-test

{ "foobarbaz" } [ "\"foo\\\nbar\\\r\nbaz\"" eval( -- obj ) ] unit-test

{ "\"abc\"" } [ "\"\\\"abc\\\"\"" eval( -- string ) ] unit-test
[ "\"" eval( -- string ) ] [ error>> unexpected? ] must-fail-with
[ "\"abc" eval( -- string ) ] [ error>> unexpected? ] must-fail-with
[ "\"abc\n\n" eval( -- string ) ] [ error>> unexpected? ] must-fail-with
[ "\"hello\"length" eval( -- string ) ] [ error>> unexpected? ] must-fail-with

{ "\"\\" } [ "\"\\" ] unit-test

{ "\e" } [ "\u00001b" ] unit-test
{ "\e" } [ "\x1b" ] unit-test
