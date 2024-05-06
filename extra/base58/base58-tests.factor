USING: base58 hex-strings strings tools.test ;

{ "" } [ "" >base58 >string ] unit-test
{ "" } [ "" base58> >string ] unit-test

{ "1" } [ B{ 0 } >base58 >string ] unit-test
{ B{ 0 } } [ "1" base58> ] unit-test

{ "11" } [ B{ 0 0 } >base58 >string ] unit-test
{ B{ 0 0 } } [ "11" base58> ] unit-test

{ "111233QC4" }
[ "000000287fb4cd" hex-string>bytes >base58 >string ] unit-test

{ "Hello World!" }
[ "2NEpo7TZRRrLZSi2U" base58> >string ] unit-test

{ "2NEpo7TZRRrLZSi2U" }
[ "Hello World!" >base58 >string ] unit-test

{ "The quick brown fox jumps over the lazy dog." }
[ "USm3fpXnKG5EUBx2ndxBDMPVciP5hGey2Jh4NDv6gmeo1LkMeiKrLJUUBk6Z" base58> >string ] unit-test

{ "USm3fpXnKG5EUBx2ndxBDMPVciP5hGey2Jh4NDv6gmeo1LkMeiKrLJUUBk6Z" }
[ "The quick brown fox jumps over the lazy dog." >base58 >string ] unit-test
