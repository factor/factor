USING: arrays assocs combinators.short-circuit grouping
http.download io.encodings.utf8 io.files io.files.temp kernel
math math.parser sequences splitting splitting.extras strings
tools.test unicode unicode.normalize.private ;
IN: unicode.normalize.tests

{ "ab\u000323\u000302cd" } [ "ab\u000302" "\u000323cd" string-append ] unit-test

{ "ab\u00064b\u000347\u00034e\u00034d\u000346" }
[ "ab\u000346\u000347\u00064b\u00034e\u00034d" dup reorder ] unit-test

{ "hello" "hello" } [ "hello" [ nfd ] keep nfkd ] unit-test

{ "\u00FB012\u002075\u00017F\u000323\u000307" "fi25s\u000323\u000307" }
[ "\u00FB012\u002075\u001E9B\u000323" [ nfd ] keep nfkd ] unit-test

{ "\u001E69" "s\u000323\u000307" } [ "\u001E69" [ nfc ] keep nfd ] unit-test
{ "\u001E0D\u000307" } [ "\u001E0B\u000323" nfc ] unit-test

{ 54620 } [ 4370 4449 4523 jamo>hangul ] unit-test
{ 4370 4449 4523 } [ 54620 hangul>jamo first3 ] unit-test
{ t } [ 54620 hangul? ] unit-test
{ f } [ 0 hangul? ] unit-test
{ "\u001112\u001161\u0011ab" } [ "\u00d55c" nfd ] unit-test
{ "\u00d55c" } [ "\u001112\u001161\u0011ab" nfc ] unit-test

! Could use simple-flat-file after some cleanup
: parse-normalization-tests ( -- tests )
    "https://downloads.factorcode.org/misc/UCD/15.1.0/NormalizationTest.txt"
    "NormalizationTest-15.1.0.txt" cache-file download-once-as
    utf8 file-lines [ "#" head? ] reject
    [ "@" head? ] split*-when
    2 <groups> [ first2 [ first ] dip 2array ] map
    values [
        [
            "#@" split first [ CHAR: \s = ] trim-tail ";" split harvest
            [ split-words [ hex> ] "" map-as ] map
        ] map
    ] map concat ;

:: check-normalization-test? ( test spec quot -- ? )
    spec [
        [
            [ 1 - test nth ] bi@ quot call( str -- str' ) =
        ] with all?
    ] assoc-all? ;

{ { } } [
    parse-normalization-tests [
        {
            [ { { 2 { 1 2 3 } } { 4 { 4 5 } } } [ nfc ] check-normalization-test? ]
            [ { { 3 { 1 2 3 } } { 5 { 4 5 } } } [ nfd ] check-normalization-test? ]
            [ { { 4 { 1 2 3 4 5 } } } [ nfkc ] check-normalization-test? ]
            [ { { 5 { 1 2 3 4 5 } } } [ nfkd ] check-normalization-test? ]
        } 1&&
    ] reject
] unit-test

{ { 4018 820 3953 3968 } }
[ { 3958 3953 820 } >string nfd >array ] unit-test
