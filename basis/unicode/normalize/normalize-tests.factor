USING: assocs combinators.short-circuit kernel locals math
math.parser sequences simple-flat-file splitting tools.test
unicode unicode.normalize.private ;
IN: unicode.normalize.tests

{ "ab\u000323\u000302cd" } [ "ab\u000302" "\u000323cd" string-append ] unit-test

{ "ab\u00064b\u000347\u00034e\u00034d\u000346" } [ "ab\u000346\u000347\u00064b\u00034e\u00034d" dup reorder ] unit-test
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

:: check? ( test spec quot -- ? )
    spec [
        [
            [ 1 - test nth ] bi@ quot call( str -- str' ) =
        ] with all?
    ] assoc-all? ;

{ 17768 { } } [
    "vocab:unicode/normalize/NormalizationTest.txt" load-data-file
    [ 5 head [ " " split [ hex> ] "" map-as ] map ] map
    [ length ] keep [
        {
            [ { { 2 { 1 2 3 } } { 4 { 4 5 } } } [ nfc ] check? ]
            [ { { 3 { 1 2 3 } } { 5 { 4 5 } } } [ nfd ] check? ]
            [ { { 4 { 1 2 3 4 5 } } } [ nfkc ] check? ]
            [ { { 5 { 1 2 3 4 5 } } } [ nfkd ] check? ]
        } 1&&
    ] reject
] unit-test
