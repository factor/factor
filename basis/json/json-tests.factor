USING: hashtables io.encodings.utf8 io.files io.files.unique
io.streams.string json json.private kernel linked-assocs
literals math namespaces sequences strings tools.test ;
IN: json.tests

! !!!!!!!!!!!!
! READER TESTS
! !!!!!!!!!!!!

{ f } [ "false" json> ] unit-test
{ t } [ "true" json> ] unit-test
{ json-null } [ "null" json> ] unit-test
{ 0 } [ "0" json> ] unit-test
{ 0 } [ "-0" json> ] unit-test
{ 102 } [ "102" json> ] unit-test
{ -102 } [ "-102" json> ] unit-test
{ 102 } [ "+102" json> ] unit-test
{ 1000.0 } [ "1.0e3" json> ] unit-test
{ 1000.0 } [ "10e2" json> ] unit-test
{ 102.0 } [ "102.0" json> ] unit-test
{ 102.5 } [ "102.5" json> ] unit-test
{ 102.5 } [ "102.50" json> ] unit-test
{ -10250.0 } [ "-102.5e2" json> ] unit-test
{ -10250.0 } [ "-102.5E+2" json> ] unit-test
{ -1.025 } [ "-102.5E-2" json> ] unit-test
{ 10.25 } [ "1025e-2" json> ] unit-test
{ 0.125 } [ "0.125" json> ] unit-test
{ -0.125 } [ "-0.125" json> ] unit-test
{ -0.00125 } [ "-0.125e-2" json> ] unit-test
{ -012.5 } [ "-0.125e+2" json> ] unit-test
{ 0.0 } [ "123e-10000000" json> ] unit-test

! not widely supported by javascript, but allowed in the grammar, and a nice
! feature to get
{ -0.0 } [ "-0.0" json> ] unit-test
{ -0.0 } [ "-0" json> ] unit-test

{ " fuzzy  pickles " } [ "  \" fuzzy  pickles \" "  json> ] unit-test
{ "while 1:\n\tpass" } [ "  \"while 1:\n\tpass\" "  json> ] unit-test
! unicode is allowed in json
{ "ß∂¬ƒ˚∆" } [ "  \"ß∂¬ƒ˚∆\""  json> ] unit-test
${ { 8 9 10 12 13 34 47 92 } >string } [ " \"\\b\\t\\n\\f\\r\\\"\\/\\\\\" " json> ] unit-test
${ { 0xabcd } >string } [ " \"\\uaBCd\" " json> ] unit-test
{ "𝄞" } [ "\"\\ud834\\udd1e\"" json> ] unit-test

{ LH{ { "a" { } } { "b" 123 } } } [ "{\"a\":[],\"b\":123}" json> ] unit-test
{ { } } [ "[]" json> ] unit-test
{ { 1 "two" 3.0 } } [ " [1, \"two\", 3.0] " json> ] unit-test
{ LH{ } } [ "{}" json> ] unit-test

! the returned hashtable should be different every time
{ LH{ } } [ "key" "value" "{}" json> ?set-at "{}" json> nip ] unit-test

{ LH{ { "US$" 1.0 } { "EU€" 1.5 } } } [ " { \"US$\":1.00, \"EU\\u20AC\":1.50 } " json> ] unit-test
{ LH{
    { "fib" { 1 1 2 3 5 8 LH{ { "etc" "etc" } } } }
    { "prime" { 2 3 5 7 11 13 } }
} } [ " {
    \"fib\": [1, 1,  2,   3,     5,         8,
        { \"etc\":\"etc\" } ],
    \"prime\":
    [ 2,3,     5,7,
11,
13
]      }
" json> ] unit-test

{ 0 } [ "      0" json> ] unit-test
{ 0 } [ "0      " json> ] unit-test
{ 0 } [ "   0   " json> ] unit-test

{ V{ LH{ { "a" "b" } } LH{ { "c" "d" } } } }
[ "{\"a\": \"b\"} {\"c\": \"d\"}" [ read-json ] with-string-reader ] unit-test

! empty objects are allowed as values in objects
{ LH{ { "foo" LH{ } } } } [ "{ \"foo\" : {}}" json> ] unit-test
! And arrays
{ { LH{ } } } [ "[{}]" json> ] unit-test

{
    "\0\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\e\x1c\x1d\x1e\x1f"
} [
    "\"\\u0000\\u0001\\u0002\\u0003\\u0004\\u0005\\u0006\\u0007\\b\\t\\n\\u000b\\f\\r\\u000e\\u000f\\u0010\\u0011\\u0012\\u0013\\u0014\\u0015\\u0016\\u0017\\u0018\\u0019\\u001a\\u001b\\u001c\\u001d\\u001e\\u001f\""
    json>
] unit-test

{ 1/0. } [ "Infinity" json> ] unit-test
{ -1/0. } [ "-Infinity" json> ] unit-test
{ t } [ "NaN" json> fp-nan? ] unit-test

[ "<!doctype html>\n<html>\n<head>\n   " json> ]
[ not-a-json-number? ] must-fail-with

! unclosed objects and mismatched brackets are not allowed
[ "[\"a\",
4
,1," json> ] must-fail

[ "[]]]" json> ]  must-fail

[ "{[: \"x\"}" json> ] must-fail

! !!!!!!!!!!!!
! WRITER TESTS
! !!!!!!!!!!!!

{ "false" } [ f >json ] unit-test
{ "true" } [ t >json ] unit-test
{ "null" } [ json-null >json ] unit-test
{ "0" } [ 0 >json ] unit-test
{ "102" } [ 102 >json ] unit-test
{ "-102" } [ -102 >json ] unit-test
{ "102.0" } [ 102.0 >json ] unit-test
{ "102.5" } [ 102.5 >json ] unit-test
{ "0.5" } [ 1/2 >json ] unit-test
{ "\"hello world\"" } [ "hello world" >json ] unit-test

{ "[1,\"two\",3.0]" } [ { 1 "two" 3.0 } >json ] unit-test
{ "{\"US$\":1.0,\"EU€\":1.5}" } [ LH{ { "US$" 1.0 } { "EU€" 1.5 } } >json ] unit-test

{ "\">json\"" } [ \ >json >json ] unit-test

{ { 0.5 } } [ { 1/2 } >json json> ] unit-test

TUPLE: person first-name age ;

{ "{\"first-name\":\"David\",\"age\":32}" }
[
    f json-friendly-keys?
    [ "David" 32 person boa >json ]
    with-variable
] unit-test

{ "{\"first_name\":\"David\",\"age\":32}" }
[
    t json-friendly-keys?
    [ "David" 32 person boa >json ]
    with-variable
] unit-test

{ "{\"1\":2,\"3\":4}" }
[ LH{ { "1" 2 } { "3" 4 } } >json ] unit-test

{ "{\"1\":2,\"3\":4}" }
[ LH{ { 1 2 } { 3 4 } } >json ] unit-test

{ "{\"\":4}" }
[ LH{ { "" 2 } { "" 4 } } >json ] unit-test

{ "{\"false\":2,\"true\":4,\"\":5}" }
[ LH{ { f 2 } { t 4 } { "" 5 } } >json ] unit-test

{ "{\"3.1\":3}" }
[ LH{ { 3.1 3 } } >json ] unit-test

{ "{\"null\":1}" }
[ LH{ { json-null 1 } } >json ] unit-test

{ "{\"Infinity\":1}" }
[ t json-allow-fp-special? [ LH{ { 1/0. 1 } } >json ] with-variable ] unit-test

{ "{\"-Infinity\":1}" }
[ t json-allow-fp-special? [ LH{ { -1/0. 1 } } >json ] with-variable ] unit-test

{ "{\"NaN\":1}" }
[ t json-allow-fp-special? [ LH{ { NAN: 333 1 } } >json ] with-variable ] unit-test

{
    "\"\\u0000\\u0001\\u0002\\u0003\\u0004\\u0005\\u0006\\u0007\\b\\t\\n\\u000b\\f\\r\\u000e\\u000f\\u0010\\u0011\\u0012\\u0013\\u0014\\u0015\\u0016\\u0017\\u0018\\u0019\\u001a\\u001b\\u001c\\u001d\\u001e\\u001f\""
} [
    "\0\x01\x02\x03\x04\x05\x06\a\b\t\n\v\f\r\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\e\x1c\x1d\x1e\x1f"
    >json
] unit-test

{ "\"\\ud834\\udd1e\"" }
[ t json-escape-unicode? [ "𝄞" >json ] with-variable ] unit-test

{ "\"\\ud800\\udc01\"" }
[ t json-escape-unicode? [ "𐀁" >json ] with-variable ] unit-test


{ t } [
    {
        LH{ { "foo" 1 } { "bar" 2 } }
        LH{ { "baz" 3 } { "qux" 4 } }
    } dup >jsonlines jsonlines> =
] unit-test

{ "6" } [ "[1,2,3]" [ sum ] rewrite-json-string ] unit-test
{ "9\n81" } [ "3\n9" [ [ sq ] map ] rewrite-jsons-string ] unit-test

{ "[1,2]" } [
    [
        "[1]" "test-json"
        [ utf8 set-file-contents ]
        [ [ { 2 } append ] rewrite-json-path ]
        [ utf8 file-contents ] tri
    ] cleanup-unique-directory
] unit-test

{ "121\n144" } [
    [
        "11\n12" "test-jsons"
        [ utf8 set-file-contents ]
        [ [ [ sq ] map ] rewrite-jsons-path ]
        [ utf8 file-contents ] tri
    ] cleanup-unique-directory
] unit-test
