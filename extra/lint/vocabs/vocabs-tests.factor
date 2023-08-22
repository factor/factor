! Copyright (C) 2022 CapitalEx
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.units continuations
formatting hash-sets hashtables io io.encodings.utf8 io.files
kernel namespaces regexp sequences sequences.deep
sequences.parser sets sorting splitting tools.test unicode
vocabs vocabs.loader ;
IN: lint.vocabs

<PRIVATE
CONSTANT: mock-file "
USING: arrays io kernel math math.parser sets
hashtables sequences vocabs ;
IN: lint.vocabs.testing

: test-one ( x y -- )
    + print ;

: test-two ( x -- x )
    dup 2array ;

: test-three ( -- x )
    HS{ } clone ;

: test-four ( x -- x )
    >bin ;

USE: math.complex
: test-five ( x -- ? )
    malformed-complex? ;

USE: math.primes
"
CONSTANT: ignore-postpone-using     "POSTPONE: USING: : nop ( -- ) ;"
CONSTANT: ingore-\-using            "\\ USING: : nop ( -- ) ;"
CONSTANT: ignore-postpone-use       "POSTPONE: USE: ignore : nop ( -- ) ;"
CONSTANT: ignore-\-use              "\\ USE: ignore : nop ( -- ) ;"
CONSTANT: ignore-in-string-one      "\"USE:\" \"USING:\" : nop ( -- ) ;"
CONSTANT: ignore-in-string-two      "\"asdfasdf USE:\" \"asdfasdf USING:\" : nop ( -- ) ;"
CONSTANT: ignore-in-string-three    "\"asdfasdf USE: asdfasdf\" : nop ( -- ) ;"
CONSTANT: ignore-in-string-four     "\"asdfasdf USE: asdfasdf\" \"asdfasff USING: asdfasdf\" : nop ( -- ) ;"
CONSTANT: ignore-string-with-quote  "\"\\\"USE:\" : nop ( -- ) ;"
CONSTANT: ignore-use-regex          "R/ USE: ignore/ : nop ( -- ) ;"
CONSTANT: ignore-using-regex        "R/ USING: ignore ;/ : nop ( -- ) ;"
CONSTANT: ignore-char-backslash     "CHAR: \\ USING: math.functions ;"
CONSTANT: empty-using-statement     "USING: ; nop ( -- ) ;"
: ---- ( -- ) "-------------------------------------------------------------------------" print ;
PRIVATE>

"next-token should get the next non-blank string in the stream:" print
{ "hello" } [ "hello world!"              <sequence-parser> next-token ] unit-test
{ "hello" } [ "\n    hello \n world!    " <sequence-parser> next-token ] unit-test

----

"next-token should ignore comments:" print
{ "world!" } [ "! hello\nworld!"                 <sequence-parser> next-token ] unit-test
{ "world!" } [ "! h\n! e\n! l\n! l\n! o\nworld!" <sequence-parser> next-token ] unit-test

----

"It should work on multiple lines, with multiple imports across the file: " print

{ { "hashtables" "math.primes" "sequences" "sets" "vocabs" } } [ mock-file find-unused-in-string ] unit-test

----

"It should ignore USE: and USING: that have been postponed: " print
{ { } } [ ignore-postpone-using find-unused-in-string ] unit-test
{ { } } [ ingore-\-using        find-unused-in-string ] unit-test
{ { } } [ ignore-postpone-use   find-unused-in-string ] unit-test
{ { } } [ ignore-\-use          find-unused-in-string ] unit-test

----

"It should ignore USE: and USING: that are in strings: " print
{ { } } [ ignore-in-string-one     find-unused-in-string ] unit-test
{ { } } [ ignore-in-string-two     find-unused-in-string ] unit-test
{ { } } [ ignore-in-string-three   find-unused-in-string ] unit-test
{ { } } [ ignore-in-string-four    find-unused-in-string ] unit-test
{ { } } [ ignore-string-with-quote find-unused-in-string ] unit-test

----

"It should ignore CHAR: \\: " print
{ { "math.functions" } } [ ignore-char-backslash find-unused-in-string ] unit-test

----

"It should ignore USE: and USING: that are in RegEx: " print
{ { } } [ ignore-use-regex   find-unused-in-string ] unit-test
{ { } } [ ignore-using-regex find-unused-in-string ] unit-test

----

"It should return empty when no imports have been found: " print
{ { } } [ empty-using-statement find-unused-in-string ] unit-test

----

"It should forget vocabs that aren't already loaded: " print
dictionary get clone 1array [ 
    "USE: bitcoin.client" find-unused-in-string drop
    dictionary get clone 
] unit-test

----
