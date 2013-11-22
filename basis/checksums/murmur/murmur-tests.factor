USING: checksums tools.test ;
IN: checksums.murmur

{ 455139366 } [ "asdf" 0 <murmur3-32> checksum-bytes ] unit-test
{ 417250299 } [ "asdf" 156 <murmur3-32> checksum-bytes ] unit-test
{ -392455434 } [ "abcde" 0 <murmur3-32> checksum-bytes ] unit-test
{ -1850534962 } [ "12345678" 0 <murmur3-32> checksum-bytes ] unit-test
{ -1710454456 } [ "12345678" 156 <murmur3-32> checksum-bytes ] unit-test
{ -734568571 } [ "hello, world!!!" 156 <murmur3-32> checksum-bytes ] unit-test
