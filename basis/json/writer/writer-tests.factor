USING: hashtables json.writer tools.test json.reader json kernel namespaces ;
IN: json.writer.tests

{ "false" } [ f >json ] unit-test
{ "true" } [ t >json ] unit-test
{ "null" } [ json-null >json ] unit-test
{ "0" } [ 0 >json ] unit-test
{ "102" } [ 102 >json ] unit-test
{ "-102" } [ -102 >json ] unit-test
{ "102.0" } [ 102.0 >json ] unit-test
{ "102.5" } [ 102.5 >json ] unit-test

{ "[1,\"two\",3.0]" } [ { 1 "two" 3.0 } >json ] unit-test
{ """{"US$":1.0,"EU€":1.5}""" } [ H{ { "US$" 1.0 } { "EU€" 1.5 } } >json ] unit-test

! Random symbols are written simply as strings
SYMBOL: testSymbol
{ """"testSymbol"""" } [ testSymbol >json ] unit-test

[ { 0.5 } ] [ { 1/2 } >json json> ] unit-test

[ "{\"b-b\":\"asdf\"}" ] 
    [ f jsvar-encode? [ "asdf" "b-b" associate >json ] with-variable ] unit-test

[ "{\"b_b\":\"asdf\"}" ]
    [ t jsvar-encode? [ "asdf" "b-b" associate >json ] with-variable ] unit-test

TUPLE: person name age a-a ;
[ "{\"name\":\"David-David\",\"age\":32,\"a_a\":{\"b_b\":\"asdf\"}}" ]
    [ t jsvar-encode? 
        [ "David-David" 32 H{ { "b-b" "asdf" } } person boa >json ] 
        with-variable ] unit-test
[ "{\"name\":\"Alpha-Beta\",\"age\":32,\"a-a\":{\"b-b\":\"asdf\"}}" ]
    [ f jsvar-encode? 
        [ "Alpha-Beta" 32 H{ { "b-b" "asdf" } } person boa >json ] 
        with-variable ] unit-test
