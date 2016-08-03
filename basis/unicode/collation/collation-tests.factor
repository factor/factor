USING: assocs grouping io.encodings.utf8 io.files kernel
math.order math.parser sequences splitting tools.test unicode ;
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
[ { "HELLO" "goodbye" "good bye" "hello" } sort-strings ]
unit-test

{ 152853 { } } [
    "vocab:unicode/collation/CollationTest_SHIFTED.txt"
    utf8 file-lines 5 tail
    [ ";" split1 drop " " split [ hex> ] "" map-as ] map
    2 clump [ length ] keep
    [ string<=> +lt+ eq? ] assoc-reject
] unit-test
