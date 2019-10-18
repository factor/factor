USING: byte-arrays checksums checksums.xxhash tools.test ;

{ 1584409650 } [ "asdf" 0 <xxhash> checksum-bytes ] unit-test
{ 4257502458 } [ "Hello World!" 12345 <xxhash> checksum-bytes ] unit-test

{ 1584409650 } [ "asdf" >byte-array 0 <xxhash> checksum-bytes ] unit-test
{ 4257502458 } [ "Hello World!" >byte-array 12345 <xxhash> checksum-bytes ] unit-test
