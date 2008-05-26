USING: io io.files splitting unicode.collation sequences kernel
io.encodings.utf8 math.parser math.order tools.test assocs
io.streams.null words combinators.lib ;
IN: unicode.collation.tests

: parse-test ( -- strings )
    "resource:extra/unicode/collation/CollationTest_SHIFTED.txt"
    utf8 file-lines 5 tail
    [ ";" split1 drop " " split [ hex> ] "" map-as ] map ;

: test-two ( str1 str2 -- )
    [ +lt+ ] -rot [ string<=> ] 2curry unit-test ;

: failures
    parse-test dup 2 <clumps>
    [ string<=> +lt+ = not ] assoc-filter dup assoc-size ;

: test-equality
    { primary= secondary= tertiary= quaternary= }
    [ execute ] 2with each ;

[ f f f f ] [ "hello" "hi" test-equality ] unit-test
[ t f f f ] [ "hello" "héllo" test-equality ] unit-test
[ t t f f ] [ "hello" "HELLO" test-equality ] unit-test
[ t t t f ] [ "hello" "h e l l o." test-equality ] unit-test
[ t t t t ] [ "hello" "\0hello\0" test-equality ] unit-test

parse-test 2 <clumps>
[ [ test-two ] assoc-each ] with-null-writer
