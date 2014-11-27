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
{ """{"US$":1.0,"EU\\u20ac\":1.5}""" } [ H{ { "US$" 1.0 } { "EU€" 1.5 } } >json ] unit-test

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

{ """{"1":2,"3":4}""" }
[ H{ { "1" 2 } { "3" 4 } } >json ] unit-test

{ """{"1":2,"3":4}""" }
[ H{ { 1 2 } { 3 4 } } >json ] unit-test

{ """{"":4}""" }
[ H{ { "" 2 } { "" 4 } } >json ] unit-test

{ """{"":5,"false":2,"true":4}""" }
[ H{ { f 2 } { t 4 } { "" 5 } } >json ] unit-test

{ """{"3.1":3}""" }
[ H{ { 3.1 3 } } >json ] unit-test

{ """{"Infinity":1}""" }
[ H{ { 1/0. 1 } } >json ] unit-test

{ """{"-Infinity":1}""" }
[ H{ { -1/0. 1 } } >json ] unit-test

{ """{"null":1}""" }
[ H{ { json-null 1 } } >json ] unit-test

{ """{"NaN":1}""" }
[ H{ { NAN: 333 1 } } >json ] unit-test

{
    "\"\\u0000\\u0001\\u0002\\u0003\\u0004\\u0005\\u0006\\u0007\\b\\t\\n\\u000b\\f\\r\\u000e\\u000f\\u0010\\u0011\\u0012\\u0013\\u0014\\u0015\\u0016\\u0017\\u0018\\u0019\\u001a\\u001b\\u001c\\u001d\\u001e\\u001f\""
} [
    "\0\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\e\x1c\x1d\x1e\x1f"
    >json
] unit-test
