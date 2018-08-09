USING: checksums checksums.bsd strings tools.test ;

{ 15816 } [ "Wikipedia" bsd checksum-bytes ] unit-test
{ 47937 } [ 10000 ch'a <string> bsd checksum-bytes ] unit-test
