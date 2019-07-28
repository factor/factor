USING: arrays assocs fry grouping io io.encodings.utf8 io.files
io.streams.null kernel math math.order math.parser multiline
random sequences splitting strings tools.test unicode words ;
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

: parse-collation-test-shifted ( -- lines )
    "vocab:unicode/UCA/CollationTest/CollationTest_SHIFTED.txt" utf8 file-lines
    [ "#@" split first ] map harvest
    [ ";" split first ] map
    [ " " split [ hex> ] "" map-as ] map ;

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
    "vocab:unicode/UCA/CollationTest/CollationTest_SHIFTED.txt" utf8 file-lines
    [ "#" head? ] reject harvest
    [ line>test-weights ] map ;

: calculate-collation ( chars collation -- collation-calculated collation-answer )
    [ >string collation-key/nfd drop ] [ { 0 } join ] bi* ;

: find-bad-collations ( pairs -- seq )
    [ first2 dupd calculate-collation 3array ] map
    [ first3 sequence= nip ] reject ;

{ { } }
[ parse-collation-test-weights find-bad-collations ] unit-test

{ { } } [
    parse-collation-test-shifted
    2 clump
    [ string<=> { +lt+ +eq+ } member? ] assoc-reject
] unit-test

! FIXME: ducet table is wrong
{ +lt+ } [ { 4019 98 } { 4019 3953 1 3968 97 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4018 820 3969 } { 3959 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4019 3953 820 3968 } { 3961 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 111355 98 } { 19968 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 40943 98 } { 64014 33 } [ >string ] bi@ string<=> ] unit-test


{ { 12748 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 3958 3953 820 } >string collation-key/nfd drop ] unit-test

{ { 12748 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 4018 820 3953 3968 } >string collation-key/nfd drop ] unit-test

{ { 12748 12741 0 32 74 32 0 2 2 2 0 65535 65535 65535 } }
[ { 4018 820 3968 3953 } >string collation-key/nfd drop ] unit-test

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

{ { 64257 32768 0 32 0 2 0 65535 614 } }
[ { 110960 33 } >string collation-key/nfd drop ] unit-test

{ { 64257 32768 0 32 0 2 0 65535 620 } }
[ { 110960 63 } >string collation-key/nfd drop ] unit-test

{ { 64257 32768 0 32 74 0 2 2 0 65535 65535 } }
[ { 110960 820 } >string collation-key/nfd drop ] unit-test

{ { 64257 32768 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 110960 97 } >string collation-key/nfd drop ] unit-test

{ { 64257 32768 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 110960 65 } >string collation-key/nfd drop ] unit-test

{ { 64257 32768 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 110960 98 } >string collation-key/nfd drop ] unit-test

{ { 64257 32769 0 32 0 2 0 65535 614 } }
[ { 110961 33 } >string collation-key/nfd drop ] unit-test

{ { 64257 32769 0 32 0 2 0 65535 620 } }
[ { 110961 63 } >string collation-key/nfd drop ] unit-test

{ { 64257 32769 0 32 74 0 2 2 0 65535 65535 } }
[ { 110961 820 } >string collation-key/nfd drop ] unit-test

{ { 64257 32769 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 110961 97 } >string collation-key/nfd drop ] unit-test

{ { 64257 32769 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 110961 65 } >string collation-key/nfd drop ] unit-test

{ { 64257 32769 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 110961 98 } >string collation-key/nfd drop ] unit-test

{ { 64257 32770 0 32 0 2 0 65535 614 } }
[ { 110962 33 } >string collation-key/nfd drop ] unit-test

{ { 64257 32770 0 32 0 2 0 65535 620 } }
[ { 110962 63 } >string collation-key/nfd drop ] unit-test

{ { 64257 32770 0 32 74 0 2 2 0 65535 65535 } }
[ { 110962 820 } >string collation-key/nfd drop ] unit-test

{ { 64257 32770 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 110962 97 } >string collation-key/nfd drop ] unit-test

{ { 64257 32770 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 110962 65 } >string collation-key/nfd drop ] unit-test

{ { 64257 32770 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 110962 98 } >string collation-key/nfd drop ] unit-test

{ { 64257 32771 0 32 0 2 0 65535 614 } }
[ { 110963 33 } >string collation-key/nfd drop ] unit-test

{ { 64257 32771 0 32 0 2 0 65535 620 } }
[ { 110963 63 } >string collation-key/nfd drop ] unit-test

{ { 64257 32771 0 32 74 0 2 2 0 65535 65535 } }
[ { 110963 820 } >string collation-key/nfd drop ] unit-test

{ { 64257 32771 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 110963 97 } >string collation-key/nfd drop ] unit-test

{ { 64257 32771 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 110963 65 } >string collation-key/nfd drop ] unit-test

{ { 64257 32771 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 110963 98 } >string collation-key/nfd drop ] unit-test

{ { 64257 33163 0 32 0 2 0 65535 614 } }
[ { 111355 33 } >string collation-key/nfd drop ] unit-test

{ { 64257 33163 0 32 0 2 0 65535 620 } }
[ { 111355 63 } >string collation-key/nfd drop ] unit-test

{ { 64257 33163 0 32 74 0 2 2 0 65535 65535 } }
[ { 111355 820 } >string collation-key/nfd drop ] unit-test

{ { 64257 33163 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 111355 97 } >string collation-key/nfd drop ] unit-test

{ { 64257 33163 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 111355 65 } >string collation-key/nfd drop ] unit-test

{ { 64257 33163 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 111355 98 } >string collation-key/nfd drop ] unit-test

{ { 64321 40934 0 32 0 2 0 65535 614 } }
[ { 40934 33 } >string collation-key/nfd drop ] unit-test

{ { 64321 40934 0 32 0 2 0 65535 620 } }
[ { 40934 63 } >string collation-key/nfd drop ] unit-test

{ { 64321 40934 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 40934 97 } >string collation-key/nfd drop ] unit-test

{ { 64321 40934 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 40934 65 } >string collation-key/nfd drop ] unit-test

{ { 64321 40934 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 40934 98 } >string collation-key/nfd drop ] unit-test

{ { 64321 40935 0 32 0 2 0 65535 614 } }
[ { 40935 33 } >string collation-key/nfd drop ] unit-test

{ { 64321 40935 0 32 0 2 0 65535 620 } }
[ { 40935 63 } >string collation-key/nfd drop ] unit-test

{ { 64321 40935 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 40935 97 } >string collation-key/nfd drop ] unit-test

{ { 64321 40935 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 40935 65 } >string collation-key/nfd drop ] unit-test

{ { 64321 40935 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 40935 98 } >string collation-key/nfd drop ] unit-test

{ { 64321 40936 0 32 0 2 0 65535 614 } }
[ { 40936 33 } >string collation-key/nfd drop ] unit-test

{ { 64321 40936 0 32 0 2 0 65535 620 } }
[ { 40936 63 } >string collation-key/nfd drop ] unit-test

{ { 64321 40936 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 40936 97 } >string collation-key/nfd drop ] unit-test

{ { 64321 40936 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 40936 65 } >string collation-key/nfd drop ] unit-test

{ { 64321 40936 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 40936 98 } >string collation-key/nfd drop ] unit-test

{ { 64321 40937 0 32 0 2 0 65535 614 } }
[ { 40937 33 } >string collation-key/nfd drop ] unit-test

{ { 64321 40937 0 32 0 2 0 65535 620 } }
[ { 40937 63 } >string collation-key/nfd drop ] unit-test

{ { 64321 40937 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 40937 97 } >string collation-key/nfd drop ] unit-test

{ { 64321 40937 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 40937 65 } >string collation-key/nfd drop ] unit-test

{ { 64321 40937 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 40937 98 } >string collation-key/nfd drop ] unit-test

{ { 64321 40938 0 32 0 2 0 65535 614 } }
[ { 40938 33 } >string collation-key/nfd drop ] unit-test

{ { 64321 40938 0 32 0 2 0 65535 620 } }
[ { 40938 63 } >string collation-key/nfd drop ] unit-test

{ { 64321 40938 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 40938 97 } >string collation-key/nfd drop ] unit-test

{ { 64321 40938 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 40938 65 } >string collation-key/nfd drop ] unit-test

{ { 64321 40938 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 40938 98 } >string collation-key/nfd drop ] unit-test

{ { 64321 40939 0 32 0 2 0 65535 614 } }
[ { 40939 33 } >string collation-key/nfd drop ] unit-test

{ { 64321 40939 0 32 0 2 0 65535 620 } }
[ { 40939 63 } >string collation-key/nfd drop ] unit-test

{ { 64321 40939 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 40939 97 } >string collation-key/nfd drop ] unit-test

{ { 64321 40939 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 40939 65 } >string collation-key/nfd drop ] unit-test

{ { 64321 40939 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 40939 98 } >string collation-key/nfd drop ] unit-test

{ { 64321 40943 0 32 0 2 0 65535 614 } }
[ { 40943 33 } >string collation-key/nfd drop ] unit-test

{ { 64321 40943 0 32 0 2 0 65535 620 } }
[ { 40943 63 } >string collation-key/nfd drop ] unit-test

{ { 64321 40943 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 40943 97 } >string collation-key/nfd drop ] unit-test

{ { 64321 40943 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 40943 65 } >string collation-key/nfd drop ] unit-test

{ { 64321 40943 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 40943 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 52912 0 32 0 2 0 65535 614 } }
[ { 183984 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 52912 0 32 0 2 0 65535 620 } }
[ { 183984 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 52912 0 32 74 0 2 2 0 65535 65535 } }
[ { 183984 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 52912 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 183984 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 52912 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 183984 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 52912 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 183984 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 52913 0 32 0 2 0 65535 614 } }
[ { 183985 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 52913 0 32 0 2 0 65535 620 } }
[ { 183985 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 52913 0 32 74 0 2 2 0 65535 65535 } }
[ { 183985 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 52913 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 183985 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 52913 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 183985 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 52913 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 183985 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 52914 0 32 0 2 0 65535 614 } }
[ { 183986 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 52914 0 32 0 2 0 65535 620 } }
[ { 183986 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 52914 0 32 74 0 2 2 0 65535 65535 } }
[ { 183986 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 52914 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 183986 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 52914 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 183986 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 52914 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 183986 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 52915 0 32 0 2 0 65535 614 } }
[ { 183987 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 52915 0 32 0 2 0 65535 620 } }
[ { 183987 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 52915 0 32 74 0 2 2 0 65535 65535 } }
[ { 183987 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 52915 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 183987 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 52915 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 183987 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 52915 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 183987 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 52916 0 32 0 2 0 65535 614 } }
[ { 183988 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 52916 0 32 0 2 0 65535 620 } }
[ { 183988 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 52916 0 32 74 0 2 2 0 65535 65535 } }
[ { 183988 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 52916 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 183988 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 52916 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 183988 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 52916 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 183988 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 52917 0 32 0 2 0 65535 614 } }
[ { 183989 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 52917 0 32 0 2 0 65535 620 } }
[ { 183989 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 52917 0 32 74 0 2 2 0 65535 65535 } }
[ { 183989 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 52917 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 183989 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 52917 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 183989 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 52917 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 183989 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 60380 0 32 0 2 0 65535 614 } }
[ { 191452 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 60380 0 32 0 2 0 65535 620 } }
[ { 191452 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 60380 0 32 74 0 2 2 0 65535 65535 } }
[ { 191452 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 60380 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 191452 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 60380 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 191452 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 60380 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 191452 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 60381 0 32 0 2 0 65535 614 } }
[ { 191453 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 60381 0 32 0 2 0 65535 620 } }
[ { 191453 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 60381 0 32 74 0 2 2 0 65535 65535 } }
[ { 191453 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 60381 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 191453 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 60381 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 191453 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 60381 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 191453 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 60382 0 32 0 2 0 65535 614 } }
[ { 191454 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 60382 0 32 0 2 0 65535 620 } }
[ { 191454 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 60382 0 32 74 0 2 2 0 65535 65535 } }
[ { 191454 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 60382 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 191454 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 60382 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 191454 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 60382 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 191454 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 60383 0 32 0 2 0 65535 614 } }
[ { 191455 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 60383 0 32 0 2 0 65535 620 } }
[ { 191455 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 60383 0 32 74 0 2 2 0 65535 65535 } }
[ { 191455 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 60383 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 191455 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 60383 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 191455 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 60383 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 191455 98 } >string collation-key/nfd drop ] unit-test

{ { 64389 60384 0 32 0 2 0 65535 614 } }
[ { 191456 33 } >string collation-key/nfd drop ] unit-test

{ { 64389 60384 0 32 0 2 0 65535 620 } }
[ { 191456 63 } >string collation-key/nfd drop ] unit-test

{ { 64389 60384 0 32 74 0 2 2 0 65535 65535 } }
[ { 191456 820 } >string collation-key/nfd drop ] unit-test

{ { 64389 60384 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 191456 97 } >string collation-key/nfd drop ] unit-test

{ { 64389 60384 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 191456 65 } >string collation-key/nfd drop ] unit-test

{ { 64389 60384 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 191456 98 } >string collation-key/nfd drop ] unit-test
