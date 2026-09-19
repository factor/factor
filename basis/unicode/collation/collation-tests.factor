USING: arrays assocs grouping http.download io.encodings.utf8
io.files io.files.temp kernel math math.order math.parser
sequences splitting strings tools.test unicode ;
IN: unicode.collation.tests

: test-equality ( str1 str2 -- ? ? ? ? )
    { primary= secondary= tertiary= quaternary= }
    [ execute( a b -- ? ) ] 2with map
    first4 ;

{ f f f f } [ "hello" "hi" test-equality ] unit-test
{ t f f f } [ "hello" "h\u0000e9llo" test-equality ] unit-test
{ t t f f } [ "hello" "HELLO" test-equality ] unit-test
{ t t t f } [ "hello" "h e l l o." test-equality ] unit-test
{ t t t t } [ "hello" "\0hello\0" test-equality ] unit-test
{ { "good bye" "goodbye" "hello" "HELLO" } }
[ { "HELLO" "goodbye" "good bye" "hello" } sort-strings ] unit-test

: collation-test-lines ( -- lines )
    "https://downloads.factorcode.org/misc/UCA/18.0.0/CollationTest_SHIFTED.txt"
    "CollationTest_SHIFTED_18.0.0.txt" cache-file download-once-as
    utf8 file-lines [ "#" head? ] reject harvest ;

: parse-collation-test-shifted ( -- lines )
    collation-test-lines
    [ ";" split first split-words [ hex> ] "" map-as ] map ;

: tail-from-last ( string char -- string' )
    '[ _ = ] dupd find-last drop 1 + tail ; inline

: line>test-weights ( string -- pair )
    ";" split1 [
        split-words [ hex> ] map
    ] [
        "#" split1 nip CHAR: [ tail-from-last
        "]" split1 drop
        "|" split 4 head
        [ split-words harvest [ hex> ] map ] map
    ] bi* 2array ;

: parse-collation-test-weights ( -- weights )
    collation-test-lines [ line>test-weights ] map ;

: calculate-collation ( chars collation -- collation-calculated collation-answer )
    [ >string collation-key/nfd drop ] [ { 0 } join ] bi* ;

: find-bad-collations ( pairs -- seq )
    [ first2 calculate-collation sequence= ] reject ;

{ { } }
[ parse-collation-test-weights find-bad-collations ] unit-test

{ { } } [
    parse-collation-test-shifted 2 clump
    [ string<=> { +lt+ +eq+ } member? ] assoc-reject
] unit-test

! U+FFFE is a field separator: "last" U+FFFE "first" sorts like the
! merged sort keys, and ties on all levels break with U+FFFE lowest.
{ { "b\u00FFFEa" "ba\u00FFFEa" } } [ { "ba\u00FFFEa" "b\u00FFFEa" } sort-strings ] unit-test
{ +lt+ } [ "a\u00FFFEb" "a\u000001\u00FFFEb" string<=> ] unit-test
