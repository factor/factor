USING: io.encodings.iana io.encodings.iana.private
io.encodings.utf8 tools.test assocs namespaces ;
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
    "EBCDIC-FI-SE-A" n>e-table get delete-at
    "csEBCDICFISEA" n>e-table get delete-at
    ebcdic-fisea e>n-table get delete-at
] unit-test
{ f } [ "EBCDIC-FI-SE-A" name>encoding ] unit-test
{ f } [ "csEBCDICFISEA" name>encoding ] unit-test
{ f } [ ebcdic-fisea encoding>name ] unit-test

[ ebcdic-fisea "foobar" register-encoding ] must-fail
{ f } [ "foobar" name>encoding ] unit-test
{ f } [ ebcdic-fisea encoding>name ] unit-test
