USING: byte-arrays checksums checksums.murmur kernel math
sequences tools.test ;

{ 455139366 } [ "asdf" >byte-array 0 <murmur3-32> checksum-bytes ] unit-test
{ 417250299 } [ "asdf" >byte-array 156 <murmur3-32> checksum-bytes ] unit-test
{ 3902511862 } [ "abcde" >byte-array 0 <murmur3-32> checksum-bytes ] unit-test
{ 2517562459 } [ "abcde" >byte-array 156 <murmur3-32> checksum-bytes ] unit-test
{ 2444432334 } [ "12345678" >byte-array 0 <murmur3-32> checksum-bytes ] unit-test
{ 2584512840 } [ "12345678" >byte-array 156 <murmur3-32> checksum-bytes ] unit-test
{ 3560398725 } [ "hello, world!!!" >byte-array 156 <murmur3-32> checksum-bytes ] unit-test

{
    {
        3903553677
        3120384252
        3928660296
        2995164002
        500661690
        2764333444
        1941147762
        161439790
        2584512840
        3803370487
        626154228
    }
} [
    "1234567890" [ length 1 + ] keep 156 <murmur3-32>
    '[ _ swap head _ checksum-bytes ] map-integers
] unit-test


{ t } [
    "1234567890" dup >byte-array [
        [ length 1 + ] keep 156 <murmur3-32>
        '[ _ swap head _ checksum-bytes ] map-integers
    ] bi@ =
] unit-test
