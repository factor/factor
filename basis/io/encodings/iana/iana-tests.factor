USING: io.encodings.iana io.encodings.iana.private
io.encodings.utf8 io.encodings.latin1 tools.test assocs namespaces ;
IN: io.encodings.iana.tests

{ utf8 } [ "UTF-8" name>encoding ] unit-test
{ utf8 } [ "utf8" name>encoding ] unit-test
{ "UTF-8" } [ utf8 encoding>name ] unit-test

! We will never implement EBCDIC-FI-SE-A
SINGLETON: ebcdic-fisea
ebcdic-fisea "EBCDIC-FI-SE-A" register-encoding
{ ebcdic-fisea } [ "EBCDIC-FI-SE-A" name>encoding ] unit-test
{ ebcdic-fisea } [ "csEBCDICFISEA" name>encoding ] unit-test
{ "EBCDIC-FI-SE-A" } [ ebcdic-fisea encoding>name ] unit-test

! Clean up after myself
{ } [
    "ebcdic-fi-se-a" n>e-table get delete-at
    "csebcdicfisea" n>e-table get delete-at
    ebcdic-fisea e>n-table get delete-at
] unit-test
{ f } [ "EBCDIC-FI-SE-A" name>encoding ] unit-test
{ f } [ "csEBCDICFISEA" name>encoding ] unit-test
{ f } [ ebcdic-fisea encoding>name ] unit-test

[ ebcdic-fisea "foobar" register-encoding ] must-fail
{ f } [ "foobar" name>encoding ] unit-test
{ f } [ ebcdic-fisea encoding>name ] unit-test

! HTTP charset names are case-insensitive.
{ latin1 } [ "iso-8859-1" name>encoding ] unit-test
{ latin1 } [ "iSo-8859-1" name>encoding ] unit-test
{ latin1 } [ "CsIsOlAtIn1" name>encoding ] unit-test
{ utf8 } [ "uTf-8" name>encoding ] unit-test
{ f } [ f name>encoding ] unit-test
