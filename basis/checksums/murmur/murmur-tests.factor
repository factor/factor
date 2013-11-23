USING: checksums tools.test ;
IN: checksums.murmur

{ 455139366 } [ "asdf" 0 <murmur3-32> checksum-bytes ] unit-test
{ 417250299 } [ "asdf" 156 <murmur3-32> checksum-bytes ] unit-test
{ 3902511862 } [ "abcde" 0 <murmur3-32> checksum-bytes ] unit-test
{ 2517562459 } [ "abcde" 156 <murmur3-32> checksum-bytes ] unit-test
{ 2444432334 } [ "12345678" 0 <murmur3-32> checksum-bytes ] unit-test
{ 2584512840 } [ "12345678" 156 <murmur3-32> checksum-bytes ] unit-test
{ 3560398725 } [ "hello, world!!!" 156 <murmur3-32> checksum-bytes ] unit-test
