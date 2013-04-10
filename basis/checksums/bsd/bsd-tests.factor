USING: checksums.bsd checksums strings tools.test ;
IN: checksums.bsd

{ 15816 } [ "Wikipedia" bsd checksum-bytes ] unit-test
{ 47937 } [ 10000 CHAR: a <string> bsd checksum-bytes ] unit-test
