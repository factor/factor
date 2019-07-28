USING: arrays assocs fry grouping io.encodings.utf8 io.files
kernel math math.order math.parser sequences splitting
strings tools.test unicode ;
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
    "vocab:unicode/UCA/CollationTest/CollationTest_SHIFTED.txt" utf8 file-lines
    [ "#" head? ] reject harvest ;

: parse-collation-test-shifted ( -- lines )
    collation-test-lines
    [ ";" split first " " split [ hex> ] "" map-as ] map ;

: tail-from-last ( string char -- string' )
    '[ _ = ] dupd find-last drop 1 + tail ; inline

: line>test-weights ( string -- pair )
    ";" split1 [
        " " split [ hex> ] map
    ] [
        "#" split1 nip CHAR: [ tail-from-last
        "]" split1 drop
        "|" split 4 head
        [ " " split harvest [ hex> ] map ] map
    ] bi* 2array ;

: parse-collation-test-weights ( -- weights )
    collation-test-lines
    [ line>test-weights ] map ;

: calculate-collation ( chars collation -- collation-calculated collation-answer )
    [ >string collation-key/nfd drop ] [ { 0 } join ] bi* ;

: find-bad-collations ( pairs -- seq )
    [ first2 calculate-collation sequence= ] reject ;

{ { } }
[ parse-collation-test-weights find-bad-collations ] unit-test

{ { } } [
    parse-collation-test-shifted
    2 clump
    [ string<=> { +lt+ +eq+ } member? ] assoc-reject
] unit-test

! FIXME: ducet table is wrong
! Fixed by fixing ducet table
! { +lt+ } [ { 4019 98 } { 4019 3953 1 3968 97 } [ >string ] bi@ string<=> ] unit-test

{ +lt+ } [ { 4018 820 3969 } { 3959 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4019 3953 820 3968 } { 3961 33 } [ >string ] bi@ string<=> ] unit-test


{ { 12748 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 3958 3953 820 } >string collation-key/nfd drop ] unit-test

{ { 12748 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 4018 820 3953 3968 } >string collation-key/nfd drop ] unit-test

! { { 12748 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
! [ { 0x0FB2 0x0334 0x0F80 0x0F71 } >string collation-key/nfd drop ] unit-test

{ { 12748 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 4018 820 3969 } >string collation-key/nfd drop ] unit-test

{ { 12750 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 3960 3953 820 } >string collation-key/nfd drop ] unit-test

{ { 12750 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 4019 820 3953 3968 } >string collation-key/nfd drop ] unit-test

{ { 12750 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 4019 820 3968 3953 } >string collation-key/nfd drop ] unit-test

{ { 12750 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 4019 3953 820 3968 } >string collation-key/nfd drop ] unit-test

{ { 12722 12741 12744 7817 0 32 32 32 32 0 2 2 2 2 0 65535 65535 65535 65535 } }
[ { 4019 3953 1 3968 97 } >string collation-key/nfd drop ] unit-test
! { 0xfb3 0x0f71 0x0334 0x0f80 }