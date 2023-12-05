USING: arrays assocs grouping hash-sets http.client
io.encodings.binary io.encodings.string io.encodings.utf8
io.files io.files.temp kernel math math.order math.parser
sequences sets splitting strings tools.test unicode ;
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
    "https://downloads.factorcode.org/misc/UCA/15.0.0/CollationTest_SHIFTED.txt"
    "CollationTest_SHIFTED_15.0.0.txt" cache-file [ ?download-to ] keep
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

! These tests actually would pass if I didn't fix up
! the ducet table for Tibetan. It took me way too long to realize
! that the Unicode committee recommends fixing Tibetan collation
! yet ships tests that collation fails if you fix it.
! (Specifically the ducet entries for { 0x0FB2 0x0F71 } and { 0x0FB3 0x0F71 }
! cause these tests to fail)
: xfailed-collation-tests ( -- seq )
    HS{
        { 3958 3953 820 }

        { 4018 820 3953 3968 }
        { 4018 820 3968 3953 }
        { 4018 3953 1 3968 97 }
        { 4018 820 3969 }

        { 3960 3953 820 }
        { 4019 820 3953 3968 }
        { 4019 820 3968 3953 }
        { 4019 3953 820 3968 }
        { 4019 3953 1 3968 97 }
    } ;

: parse-collation-test-weights ( -- weights )
    collation-test-lines
    [ line>test-weights ] map
    [ first xfailed-collation-tests in? ] reject ;

: calculate-collation ( chars collation -- collation-calculated collation-answer )
    [ >string collation-key/nfd drop ] [ { 0 } join ] bi* ;

: find-bad-collations ( pairs -- seq )
    [ first2 calculate-collation sequence= ] reject ;

{ { } }
[ parse-collation-test-weights find-bad-collations ] unit-test

{ { } } [
    parse-collation-test-shifted
    2 clump >hash-set

    ! Remove these two expected-fail Tibetan collation comparison tests
    ! They are bad tests once you fix up the ducet table with { 0x0FB2 0x0F71 } and { 0x0FB3 0x0F71 }
    {
        { { 4018 820 3969 } { 3959 33 } }
        { { 4019 3953 820 3968 } { 3961 33 } }
        { { 4019 98 } { 4019 3953 1 3968 97 } }
        { { 4028 98 } { 4018 3953 1 3968 97 } }
    } [ [ >string ] bi@ ] assoc-map >hash-set diff members

    [ string<=> { +lt+ +eq+ } member? ] assoc-reject
] unit-test

! XXX: Once again, these tests pass if you don't
! fix up the ducet table for { 0x0FB2 0x0F71 } and { 0x0FB3 0x0F71 }
! { +lt+ } [ { 4018 820 3969 } { 3959 33 } [ >string ] bi@ string<=> ] unit-test
! { +lt+ } [ { 4019 3953 820 3968 } { 3961 33 } [ >string ] bi@ string<=> ] unit-test
