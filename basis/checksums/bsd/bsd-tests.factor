USING: checksums checksums.bsd strings tools.test ;

{ 15816 } [ "Wikipedia" bsd checksum-bytes ] unit-test
{ 47937 } [ 10000 CHAR: a <string> bsd checksum-bytes ] unit-test
