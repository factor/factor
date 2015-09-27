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
{ "0.5" } [ 1/2 >json ] unit-test
{ "\"hello world\"" } [ "hello world" >json ] unit-test

{ "[1,\"two\",3.0]" } [ { 1 "two" 3.0 } >json ] unit-test
{ "{\"US$\":1.0,\"EU€\":1.5}" } [ H{ { "US$" 1.0 } { "EU€" 1.5 } } >json ] unit-test

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
[ H{ { "1" 2 } { "3" 4 } } >json ] unit-test

{ "{\"1\":2,\"3\":4}" }
[ H{ { 1 2 } { 3 4 } } >json ] unit-test

{ "{\"\":4}" }
[ H{ { "" 2 } { "" 4 } } >json ] unit-test

{ "{\"true\":4,\"false\":2,\"\":5}" }
[ H{ { f 2 } { t 4 } { "" 5 } } >json ] unit-test

{ "{\"3.1\":3}" }
[ H{ { 3.1 3 } } >json ] unit-test

{ "{\"null\":1}" }
[ H{ { json-null 1 } } >json ] unit-test

{ "{\"Infinity\":1}" }
[ t json-allow-fp-special? [ H{ { 1/0. 1 } } >json ] with-variable ] unit-test

{ "{\"-Infinity\":1}" }
[ t json-allow-fp-special? [ H{ { -1/0. 1 } } >json ] with-variable ] unit-test

{ "{\"NaN\":1}" }
[ t json-allow-fp-special? [ H{ { NAN: 333 1 } } >json ] with-variable ] unit-test

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
