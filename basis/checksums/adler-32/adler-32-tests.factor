USING: checksums.adler-32 checksums strings tools.test ;
IN: checksums.adler-32.tests

[ 300286872 ] [ "Wikipedia" adler-32 checksum-bytes ] unit-test
[ 2679885283 ] [ 10000 CHAR: a <string> adler-32 checksum-bytes ] unit-test
