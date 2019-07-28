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

{ +lt+ } [ { 4018 820 3969 } { 3959 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 4019 3953 820 3968 } { 3961 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 111355 98 } { 19968 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 40943 98 } { 64014 33 } [ >string ] bi@ string<=> ] unit-test
{ +lt+ } [ { 191456 98 } { 888 33 } [ >string ] bi@ string<=> ] unit-test


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

{ { 64449 55296 0 32 0 2 0 65535 614 } }
[ { 55296 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 55296 0 32 0 2 0 65535 620 } }
[ { 55296 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 55296 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 55296 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 55296 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 55296 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 55296 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 55296 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 55297 0 32 0 2 0 65535 614 } }
[ { 55297 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 55297 0 32 0 2 0 65535 620 } }
[ { 55297 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 55297 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 55297 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 55297 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 55297 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 55297 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 55297 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 55298 0 32 0 2 0 65535 614 } }
[ { 55298 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 55298 0 32 0 2 0 65535 620 } }
[ { 55298 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 55298 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 55298 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 55298 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 55298 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 55298 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 55298 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 55299 0 32 0 2 0 65535 614 } }
[ { 55299 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 55299 0 32 0 2 0 65535 620 } }
[ { 55299 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 55299 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 55299 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 55299 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 55299 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 55299 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 55299 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 56320 0 32 0 2 0 65535 614 } }
[ { 56320 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 56320 0 32 0 2 0 65535 620 } }
[ { 56320 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 56320 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 56320 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 56320 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 56320 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 56320 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 56320 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 57343 0 32 0 2 0 65535 614 } }
[ { 57343 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 57343 0 32 0 2 0 65535 620 } }
[ { 57343 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 57343 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 57343 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 57343 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 57343 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 57343 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 57343 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 64976 0 32 0 2 0 65535 614 } }
[ { 64976 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 64976 0 32 0 2 0 65535 620 } }
[ { 64976 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 64976 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 64976 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 64976 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 64976 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 64976 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 64976 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 64977 0 32 0 2 0 65535 614 } }
[ { 64977 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 64977 0 32 0 2 0 65535 620 } }
[ { 64977 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 64977 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 64977 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 64977 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 64977 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 64977 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 64977 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 64978 0 32 0 2 0 65535 614 } }
[ { 64978 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 64978 0 32 0 2 0 65535 620 } }
[ { 64978 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 64978 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 64978 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 64978 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 64978 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 64978 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 64978 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 64979 0 32 0 2 0 65535 614 } }
[ { 64979 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 64979 0 32 0 2 0 65535 620 } }
[ { 64979 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 64979 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 64979 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 64979 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 64979 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 64979 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 64979 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 65534 0 32 0 2 0 65535 614 } }
[ { 65534 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 65534 0 32 0 2 0 65535 620 } }
[ { 65534 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 65534 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 65534 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 65534 98 } >string collation-key/nfd drop ] unit-test

{ { 64449 65535 0 32 0 2 0 65535 614 } }
[ { 65535 33 } >string collation-key/nfd drop ] unit-test

{ { 64449 65535 0 32 0 2 0 65535 620 } }
[ { 65535 63 } >string collation-key/nfd drop ] unit-test

{ { 64449 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 65535 97 } >string collation-key/nfd drop ] unit-test

{ { 64449 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 65535 65 } >string collation-key/nfd drop ] unit-test

{ { 64449 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 65535 98 } >string collation-key/nfd drop ] unit-test

{ { 64451 65534 0 32 0 2 0 65535 614 } }
[ { 131070 33 } >string collation-key/nfd drop ] unit-test

{ { 64451 65534 0 32 0 2 0 65535 620 } }
[ { 131070 63 } >string collation-key/nfd drop ] unit-test

{ { 64451 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 131070 820 } >string collation-key/nfd drop ] unit-test

{ { 64451 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 131070 97 } >string collation-key/nfd drop ] unit-test

{ { 64451 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 131070 65 } >string collation-key/nfd drop ] unit-test

{ { 64451 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 131070 98 } >string collation-key/nfd drop ] unit-test

{ { 64451 65535 0 32 0 2 0 65535 614 } }
[ { 131071 33 } >string collation-key/nfd drop ] unit-test

{ { 64451 65535 0 32 0 2 0 65535 620 } }
[ { 131071 63 } >string collation-key/nfd drop ] unit-test

{ { 64451 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 131071 820 } >string collation-key/nfd drop ] unit-test

{ { 64451 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 131071 97 } >string collation-key/nfd drop ] unit-test

{ { 64451 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 131071 65 } >string collation-key/nfd drop ] unit-test

{ { 64451 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 131071 98 } >string collation-key/nfd drop ] unit-test

{ { 64453 65534 0 32 0 2 0 65535 614 } }
[ { 196606 33 } >string collation-key/nfd drop ] unit-test

{ { 64453 65534 0 32 0 2 0 65535 620 } }
[ { 196606 63 } >string collation-key/nfd drop ] unit-test

{ { 64453 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 196606 820 } >string collation-key/nfd drop ] unit-test

{ { 64453 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 196606 97 } >string collation-key/nfd drop ] unit-test

{ { 64453 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 196606 65 } >string collation-key/nfd drop ] unit-test

{ { 64453 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 196606 98 } >string collation-key/nfd drop ] unit-test

{ { 64453 65535 0 32 0 2 0 65535 614 } }
[ { 196607 33 } >string collation-key/nfd drop ] unit-test

{ { 64453 65535 0 32 0 2 0 65535 620 } }
[ { 196607 63 } >string collation-key/nfd drop ] unit-test

{ { 64453 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 196607 820 } >string collation-key/nfd drop ] unit-test

{ { 64453 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 196607 97 } >string collation-key/nfd drop ] unit-test

{ { 64453 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 196607 65 } >string collation-key/nfd drop ] unit-test

{ { 64453 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 196607 98 } >string collation-key/nfd drop ] unit-test

{ { 64455 65534 0 32 0 2 0 65535 614 } }
[ { 262142 33 } >string collation-key/nfd drop ] unit-test

{ { 64455 65534 0 32 0 2 0 65535 620 } }
[ { 262142 63 } >string collation-key/nfd drop ] unit-test

{ { 64455 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 262142 820 } >string collation-key/nfd drop ] unit-test

{ { 64455 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 262142 97 } >string collation-key/nfd drop ] unit-test

{ { 64455 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 262142 65 } >string collation-key/nfd drop ] unit-test

{ { 64455 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 262142 98 } >string collation-key/nfd drop ] unit-test

{ { 64455 65535 0 32 0 2 0 65535 614 } }
[ { 262143 33 } >string collation-key/nfd drop ] unit-test

{ { 64455 65535 0 32 0 2 0 65535 620 } }
[ { 262143 63 } >string collation-key/nfd drop ] unit-test

{ { 64455 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 262143 820 } >string collation-key/nfd drop ] unit-test

{ { 64455 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 262143 97 } >string collation-key/nfd drop ] unit-test

{ { 64455 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 262143 65 } >string collation-key/nfd drop ] unit-test

{ { 64455 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 262143 98 } >string collation-key/nfd drop ] unit-test

{ { 64457 65534 0 32 0 2 0 65535 614 } }
[ { 327678 33 } >string collation-key/nfd drop ] unit-test

{ { 64457 65534 0 32 0 2 0 65535 620 } }
[ { 327678 63 } >string collation-key/nfd drop ] unit-test

{ { 64457 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 327678 820 } >string collation-key/nfd drop ] unit-test

{ { 64457 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 327678 97 } >string collation-key/nfd drop ] unit-test

{ { 64457 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 327678 65 } >string collation-key/nfd drop ] unit-test

{ { 64457 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 327678 98 } >string collation-key/nfd drop ] unit-test

{ { 64457 65535 0 32 0 2 0 65535 614 } }
[ { 327679 33 } >string collation-key/nfd drop ] unit-test

{ { 64457 65535 0 32 0 2 0 65535 620 } }
[ { 327679 63 } >string collation-key/nfd drop ] unit-test

{ { 64457 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 327679 820 } >string collation-key/nfd drop ] unit-test

{ { 64457 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 327679 97 } >string collation-key/nfd drop ] unit-test

{ { 64457 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 327679 65 } >string collation-key/nfd drop ] unit-test

{ { 64457 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 327679 98 } >string collation-key/nfd drop ] unit-test

{ { 64459 65534 0 32 0 2 0 65535 614 } }
[ { 393214 33 } >string collation-key/nfd drop ] unit-test

{ { 64459 65534 0 32 0 2 0 65535 620 } }
[ { 393214 63 } >string collation-key/nfd drop ] unit-test

{ { 64459 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 393214 820 } >string collation-key/nfd drop ] unit-test

{ { 64459 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 393214 97 } >string collation-key/nfd drop ] unit-test

{ { 64459 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 393214 65 } >string collation-key/nfd drop ] unit-test

{ { 64459 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 393214 98 } >string collation-key/nfd drop ] unit-test

{ { 64459 65535 0 32 0 2 0 65535 614 } }
[ { 393215 33 } >string collation-key/nfd drop ] unit-test

{ { 64459 65535 0 32 0 2 0 65535 620 } }
[ { 393215 63 } >string collation-key/nfd drop ] unit-test

{ { 64459 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 393215 820 } >string collation-key/nfd drop ] unit-test

{ { 64459 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 393215 97 } >string collation-key/nfd drop ] unit-test

{ { 64459 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 393215 65 } >string collation-key/nfd drop ] unit-test

{ { 64459 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 393215 98 } >string collation-key/nfd drop ] unit-test

{ { 64461 65534 0 32 0 2 0 65535 614 } }
[ { 458750 33 } >string collation-key/nfd drop ] unit-test

{ { 64461 65534 0 32 0 2 0 65535 620 } }
[ { 458750 63 } >string collation-key/nfd drop ] unit-test

{ { 64461 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 458750 820 } >string collation-key/nfd drop ] unit-test

{ { 64461 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 458750 97 } >string collation-key/nfd drop ] unit-test

{ { 64461 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 458750 65 } >string collation-key/nfd drop ] unit-test

{ { 64461 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 458750 98 } >string collation-key/nfd drop ] unit-test

{ { 64461 65535 0 32 0 2 0 65535 614 } }
[ { 458751 33 } >string collation-key/nfd drop ] unit-test

{ { 64461 65535 0 32 0 2 0 65535 620 } }
[ { 458751 63 } >string collation-key/nfd drop ] unit-test

{ { 64461 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 458751 820 } >string collation-key/nfd drop ] unit-test

{ { 64461 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 458751 97 } >string collation-key/nfd drop ] unit-test

{ { 64461 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 458751 65 } >string collation-key/nfd drop ] unit-test

{ { 64461 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 458751 98 } >string collation-key/nfd drop ] unit-test

{ { 64463 65534 0 32 0 2 0 65535 614 } }
[ { 524286 33 } >string collation-key/nfd drop ] unit-test

{ { 64463 65534 0 32 0 2 0 65535 620 } }
[ { 524286 63 } >string collation-key/nfd drop ] unit-test

{ { 64463 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 524286 820 } >string collation-key/nfd drop ] unit-test

{ { 64463 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 524286 97 } >string collation-key/nfd drop ] unit-test

{ { 64463 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 524286 65 } >string collation-key/nfd drop ] unit-test

{ { 64463 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 524286 98 } >string collation-key/nfd drop ] unit-test

{ { 64463 65535 0 32 0 2 0 65535 614 } }
[ { 524287 33 } >string collation-key/nfd drop ] unit-test

{ { 64463 65535 0 32 0 2 0 65535 620 } }
[ { 524287 63 } >string collation-key/nfd drop ] unit-test

{ { 64463 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 524287 820 } >string collation-key/nfd drop ] unit-test

{ { 64463 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 524287 97 } >string collation-key/nfd drop ] unit-test

{ { 64463 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 524287 65 } >string collation-key/nfd drop ] unit-test

{ { 64463 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 524287 98 } >string collation-key/nfd drop ] unit-test

{ { 64465 65534 0 32 0 2 0 65535 614 } }
[ { 589822 33 } >string collation-key/nfd drop ] unit-test

{ { 64465 65534 0 32 0 2 0 65535 620 } }
[ { 589822 63 } >string collation-key/nfd drop ] unit-test

{ { 64465 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 589822 820 } >string collation-key/nfd drop ] unit-test

{ { 64465 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 589822 97 } >string collation-key/nfd drop ] unit-test

{ { 64465 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 589822 65 } >string collation-key/nfd drop ] unit-test

{ { 64465 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 589822 98 } >string collation-key/nfd drop ] unit-test

{ { 64465 65535 0 32 0 2 0 65535 614 } }
[ { 589823 33 } >string collation-key/nfd drop ] unit-test

{ { 64465 65535 0 32 0 2 0 65535 620 } }
[ { 589823 63 } >string collation-key/nfd drop ] unit-test

{ { 64465 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 589823 820 } >string collation-key/nfd drop ] unit-test

{ { 64465 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 589823 97 } >string collation-key/nfd drop ] unit-test

{ { 64465 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 589823 65 } >string collation-key/nfd drop ] unit-test

{ { 64465 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 589823 98 } >string collation-key/nfd drop ] unit-test

{ { 64467 65534 0 32 0 2 0 65535 614 } }
[ { 655358 33 } >string collation-key/nfd drop ] unit-test

{ { 64467 65534 0 32 0 2 0 65535 620 } }
[ { 655358 63 } >string collation-key/nfd drop ] unit-test

{ { 64467 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 655358 820 } >string collation-key/nfd drop ] unit-test

{ { 64467 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 655358 97 } >string collation-key/nfd drop ] unit-test

{ { 64467 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 655358 65 } >string collation-key/nfd drop ] unit-test

{ { 64467 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 655358 98 } >string collation-key/nfd drop ] unit-test

{ { 64467 65535 0 32 0 2 0 65535 614 } }
[ { 655359 33 } >string collation-key/nfd drop ] unit-test

{ { 64467 65535 0 32 0 2 0 65535 620 } }
[ { 655359 63 } >string collation-key/nfd drop ] unit-test

{ { 64467 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 655359 820 } >string collation-key/nfd drop ] unit-test

{ { 64467 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 655359 97 } >string collation-key/nfd drop ] unit-test

{ { 64467 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 655359 65 } >string collation-key/nfd drop ] unit-test

{ { 64467 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 655359 98 } >string collation-key/nfd drop ] unit-test

{ { 64469 65534 0 32 0 2 0 65535 614 } }
[ { 720894 33 } >string collation-key/nfd drop ] unit-test

{ { 64469 65534 0 32 0 2 0 65535 620 } }
[ { 720894 63 } >string collation-key/nfd drop ] unit-test

{ { 64469 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 720894 820 } >string collation-key/nfd drop ] unit-test

{ { 64469 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 720894 97 } >string collation-key/nfd drop ] unit-test

{ { 64469 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 720894 65 } >string collation-key/nfd drop ] unit-test

{ { 64469 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 720894 98 } >string collation-key/nfd drop ] unit-test

{ { 64469 65535 0 32 0 2 0 65535 614 } }
[ { 720895 33 } >string collation-key/nfd drop ] unit-test

{ { 64469 65535 0 32 0 2 0 65535 620 } }
[ { 720895 63 } >string collation-key/nfd drop ] unit-test

{ { 64469 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 720895 820 } >string collation-key/nfd drop ] unit-test

{ { 64469 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 720895 97 } >string collation-key/nfd drop ] unit-test

{ { 64469 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 720895 65 } >string collation-key/nfd drop ] unit-test

{ { 64469 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 720895 98 } >string collation-key/nfd drop ] unit-test

{ { 64471 65534 0 32 0 2 0 65535 614 } }
[ { 786430 33 } >string collation-key/nfd drop ] unit-test

{ { 64471 65534 0 32 0 2 0 65535 620 } }
[ { 786430 63 } >string collation-key/nfd drop ] unit-test

{ { 64471 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 786430 820 } >string collation-key/nfd drop ] unit-test

{ { 64471 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 786430 97 } >string collation-key/nfd drop ] unit-test

{ { 64471 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 786430 65 } >string collation-key/nfd drop ] unit-test

{ { 64471 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 786430 98 } >string collation-key/nfd drop ] unit-test

{ { 64471 65535 0 32 0 2 0 65535 614 } }
[ { 786431 33 } >string collation-key/nfd drop ] unit-test

{ { 64471 65535 0 32 0 2 0 65535 620 } }
[ { 786431 63 } >string collation-key/nfd drop ] unit-test

{ { 64471 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 786431 820 } >string collation-key/nfd drop ] unit-test

{ { 64471 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 786431 97 } >string collation-key/nfd drop ] unit-test

{ { 64471 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 786431 65 } >string collation-key/nfd drop ] unit-test

{ { 64471 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 786431 98 } >string collation-key/nfd drop ] unit-test

{ { 64473 65534 0 32 0 2 0 65535 614 } }
[ { 851966 33 } >string collation-key/nfd drop ] unit-test

{ { 64473 65534 0 32 0 2 0 65535 620 } }
[ { 851966 63 } >string collation-key/nfd drop ] unit-test

{ { 64473 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 851966 820 } >string collation-key/nfd drop ] unit-test

{ { 64473 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 851966 97 } >string collation-key/nfd drop ] unit-test

{ { 64473 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 851966 65 } >string collation-key/nfd drop ] unit-test

{ { 64473 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 851966 98 } >string collation-key/nfd drop ] unit-test

{ { 64473 65535 0 32 0 2 0 65535 614 } }
[ { 851967 33 } >string collation-key/nfd drop ] unit-test

{ { 64473 65535 0 32 0 2 0 65535 620 } }
[ { 851967 63 } >string collation-key/nfd drop ] unit-test

{ { 64473 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 851967 820 } >string collation-key/nfd drop ] unit-test

{ { 64473 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 851967 97 } >string collation-key/nfd drop ] unit-test

{ { 64473 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 851967 65 } >string collation-key/nfd drop ] unit-test

{ { 64473 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 851967 98 } >string collation-key/nfd drop ] unit-test

{ { 64475 65534 0 32 0 2 0 65535 614 } }
[ { 917502 33 } >string collation-key/nfd drop ] unit-test

{ { 64475 65534 0 32 0 2 0 65535 620 } }
[ { 917502 63 } >string collation-key/nfd drop ] unit-test

{ { 64475 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 917502 820 } >string collation-key/nfd drop ] unit-test

{ { 64475 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 917502 97 } >string collation-key/nfd drop ] unit-test

{ { 64475 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 917502 65 } >string collation-key/nfd drop ] unit-test

{ { 64475 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 917502 98 } >string collation-key/nfd drop ] unit-test

{ { 64475 65535 0 32 0 2 0 65535 614 } }
[ { 917503 33 } >string collation-key/nfd drop ] unit-test

{ { 64475 65535 0 32 0 2 0 65535 620 } }
[ { 917503 63 } >string collation-key/nfd drop ] unit-test

{ { 64475 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 917503 820 } >string collation-key/nfd drop ] unit-test

{ { 64475 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 917503 97 } >string collation-key/nfd drop ] unit-test

{ { 64475 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 917503 65 } >string collation-key/nfd drop ] unit-test

{ { 64475 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 917503 98 } >string collation-key/nfd drop ] unit-test

{ { 64477 65534 0 32 0 2 0 65535 614 } }
[ { 983038 33 } >string collation-key/nfd drop ] unit-test

{ { 64477 65534 0 32 0 2 0 65535 620 } }
[ { 983038 63 } >string collation-key/nfd drop ] unit-test

{ { 64477 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 983038 820 } >string collation-key/nfd drop ] unit-test

{ { 64477 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 983038 97 } >string collation-key/nfd drop ] unit-test

{ { 64477 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 983038 65 } >string collation-key/nfd drop ] unit-test

{ { 64477 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 983038 98 } >string collation-key/nfd drop ] unit-test

{ { 64477 65535 0 32 0 2 0 65535 614 } }
[ { 983039 33 } >string collation-key/nfd drop ] unit-test

{ { 64477 65535 0 32 0 2 0 65535 620 } }
[ { 983039 63 } >string collation-key/nfd drop ] unit-test

{ { 64477 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 983039 820 } >string collation-key/nfd drop ] unit-test

{ { 64477 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 983039 97 } >string collation-key/nfd drop ] unit-test

{ { 64477 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 983039 65 } >string collation-key/nfd drop ] unit-test

{ { 64477 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 983039 98 } >string collation-key/nfd drop ] unit-test

{ { 64481 65534 0 32 0 2 0 65535 614 } }
[ { 1114110 33 } >string collation-key/nfd drop ] unit-test

{ { 64481 65534 0 32 0 2 0 65535 620 } }
[ { 1114110 63 } >string collation-key/nfd drop ] unit-test

{ { 64481 65534 0 32 74 0 2 2 0 65535 65535 } }
[ { 1114110 820 } >string collation-key/nfd drop ] unit-test

{ { 64481 65534 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 1114110 97 } >string collation-key/nfd drop ] unit-test

{ { 64481 65534 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 1114110 65 } >string collation-key/nfd drop ] unit-test

{ { 64481 65534 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 1114110 98 } >string collation-key/nfd drop ] unit-test

{ { 64481 65535 0 32 0 2 0 65535 614 } }
[ { 1114111 33 } >string collation-key/nfd drop ] unit-test

{ { 64481 65535 0 32 0 2 0 65535 620 } }
[ { 1114111 63 } >string collation-key/nfd drop ] unit-test

{ { 64481 65535 0 32 74 0 2 2 0 65535 65535 } }
[ { 1114111 820 } >string collation-key/nfd drop ] unit-test

{ { 64481 65535 7817 0 32 32 0 2 2 0 65535 65535 } }
[ { 1114111 97 } >string collation-key/nfd drop ] unit-test

{ { 64481 65535 7817 0 32 32 0 2 8 0 65535 65535 } }
[ { 1114111 65 } >string collation-key/nfd drop ] unit-test

{ { 64481 65535 7843 0 32 32 0 2 2 0 65535 65535 } }
[ { 1114111 98 } >string collation-key/nfd drop ] unit-test
