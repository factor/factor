USING: hashtables io.streams.string json json.reader
json.reader.private kernel literals math strings tools.test ;

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

{ " fuzzy  pickles " } [ "  \" fuzzy  pickles \" "  json> ] unit-test
{ "while 1:\n\tpass" } [ "  \"while 1:\n\tpass\" "  json> ] unit-test
! unicode is allowed in json
{ "ß∂¬ƒ˚∆" } [ "  \"ß∂¬ƒ˚∆\""  json> ] unit-test
${ { 8 9 10 12 13 34 47 92 } >string } [ " \"\\b\\t\\n\\f\\r\\\"\\/\\\\\" " json> ] unit-test
${ { 0xabcd } >string } [ " \"\\uaBCd\" " json> ] unit-test
{ "𝄞" } [ "\"\\ud834\\udd1e\"" json> ] unit-test

{ H{ { "a" { } } { "b" 123 } } } [ "{\"a\":[],\"b\":123}" json> ] unit-test
{ { } } [ "[]" json> ] unit-test
{ { 1 "two" 3.0 } } [ " [1, \"two\", 3.0] " json> ] unit-test
{ H{ } } [ "{}" json> ] unit-test

! the returned hashtable should be different every time
{ H{ } } [ "key" "value" "{}" json> ?set-at "{}" json> nip ] unit-test

{ H{ { "US$" 1.0 } { "EU€" 1.5 } } } [ " { \"US$\":1.00, \"EU\\u20AC\":1.50 } " json> ] unit-test
{ H{
    { "fib" { 1 1 2 3 5 8 H{ { "etc" "etc" } } } }
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

{ V{ H{ { "a" "b" } } H{ { "c" "d" } } } }
[ "{\"a\": \"b\"} {\"c\": \"d\"}" [ read-json-objects ] with-string-reader ] unit-test

! empty objects are allowed as values in objects
{ H{ { "foo" H{ } } } } [ "{ \"foo\" : {}}" json> ] unit-test
! And arrays
{ { H{ } } } [ "[{}]" json> ] unit-test

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

{ H{ } } [ "" json> ] unit-test
