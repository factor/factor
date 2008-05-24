USING: io io.files splitting unicode.collation sequences kernel
io.encodings.utf8 math.parser math.order tools.test assocs ;
IN: unicode.collation.tests

: parse-test ( -- strings )
    "resource:extra/unicode/collation/CollationTest_SHIFTED.txt"
    utf8 file-lines 5 tail
    [ ";" split1 drop " " split [ hex> ] "" map-as ] map ;

: test-two ( str1 str2 -- )
    [ +lt+ ] -rot [ string<=> ] 2curry unit-test ;

: find-failure
    parse-test dup 2 <clumps>
    [ string<=> +lt+ = not ] assoc-find drop ;

: (find-failure)
    dup 2 <clumps>
    [ string<=> +lt+ = not ] assoc-find drop ;

: failures
    parse-test dup 2 <clumps>
    [ string<=> +lt+ = not ] assoc-filter dup assoc-size ;
