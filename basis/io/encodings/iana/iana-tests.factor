USING: io.encodings.iana io.encodings.iana.private
io.encodings.utf8 tools.test assocs ;
IN: io.encodings.iana.tests

[ utf8 ] [ "UTF-8" name>encoding ] unit-test
[ utf8 ] [ "utf8" name>encoding ] unit-test
[ "UTF-8" ] [ utf8 encoding>name ] unit-test

! We will never implement EBCDIC-FI-SE-A
SINGLETON: ebcdic-fisea
ebcdic-fisea "EBCDIC-FI-SE-A" register-encoding
[ ebcdic-fisea ] [ "EBCDIC-FI-SE-A" name>encoding ] unit-test
[ ebcdic-fisea ] [ "csEBCDICFISEA" name>encoding ] unit-test
[ "EBCDIC-FI-SE-A" ] [ ebcdic-fisea encoding>name ] unit-test

! Clean up after myself
[ ] [
    "EBCDIC-FI-SE-A" n>e-table delete-at
    "csEBCDICFISEA" n>e-table delete-at
    ebcdic-fisea e>n-table delete-at
] unit-test
[ "EBCDIC-FI-SE-A" name>encoding ] must-fail
[ "csEBCDICFISEA" name>encoding ] must-fail
[ ebcdic-fisea encoding>name ] must-fail

[ ebcdic-fisea "foobar" register-encoding ] must-fail
[ "foobar" name>encoding ] must-fail
[ ebcdic-fisea encoding>name ] must-fail
