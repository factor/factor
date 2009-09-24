USING: arrays json.reader kernel strings tools.test
hashtables json ;
IN: json.reader.tests

{ f } [ "false" json> ] unit-test
{ t } [ "true" json> ] unit-test
{ json-null } [ "null" json> ] unit-test
{ 0 } [ "0" json> ] unit-test
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
{ 10.25 } [ "1025e-2" json> ] unit-test
{ 0.125 } [ "0.125" json> ] unit-test
{ -0.125 } [ "-0.125" json> ] unit-test
{ -0.00125 } [ "-0.125e-2" json> ] unit-test
{ -012.5 } [ "-0.125e+2" json> ] unit-test

! not widely supported by javascript, but allowed in the grammar, and a nice
! feature to get
{ -0.0 } [ "-0.0" json> ] unit-test

{ " fuzzy  pickles " } [ """  " fuzzy  pickles " """  json> ] unit-test
{ "while 1:\n\tpass" } [ """  "while 1:\n\tpass" """  json> ] unit-test
! unicode is allowed in json
{ "ß∂¬ƒ˚∆" } [ """  "ß∂¬ƒ˚∆""""  json> ] unit-test
{ 8 9 10 12 13 34 47 92 } >string 1array [ """ "\\b\\t\\n\\f\\r\\"\\/\\\\" """ json> ] unit-test
{ HEX: abcd } >string 1array [ """ "\\uaBCd" """ json> ] unit-test

{ H{ { "a" { } } { "b" 123 } } } [ "{\"a\":[],\"b\":123}" json> ] unit-test
{ { } } [ "[]" json> ] unit-test 
{ { 1 "two" 3.0 } } [ """ [1, "two", 3.0] """ json> ] unit-test
{ H{ } } [ "{}" json> ] unit-test

! the returned hashtable should be different every time
{ H{ } } [ "key" "value" "{}" json> ?set-at "{}" json> nip ] unit-test

{ H{ { "US$" 1.0 } { "EU€" 1.5 } } } [ """ { "US$":1.00, "EU\\u20AC":1.50 } """ json> ] unit-test
{ H{
    { "fib" { 1 1 2 3 5 8 H{ { "etc" "etc" } } } }
    { "prime" { 2 3 5 7 11 13 } }
} } [ """ {
    "fib": [1, 1,  2,   3,     5,         8,
        { "etc":"etc" } ],
    "prime":
    [ 2,3,     5,7,
11,
13
]      }
""" json> ] unit-test

{ 0 } [ "      0" json> ] unit-test
{ 0 } [ "0      " json> ] unit-test
{ 0 } [ "   0   " json> ] unit-test
