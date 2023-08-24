USING: base62 math.parser strings tools.test ;

{ "" } [ "" >base62 >string ] unit-test
{ "" } [ "" base62> >string ] unit-test

{ "0" } [ B{ 0 } >base62 >string ] unit-test
{ B{ 0 } } [ "0" base62> ] unit-test

{ "00" } [ B{ 0 0 } >base62 >string ] unit-test
{ B{ 0 0 } } [ "00" base62> ] unit-test

{ "Q0DRQksv" } [ "SIMPLE" >base62 >string ] unit-test
{ "SIMPLE" } [ "Q0DRQksv" base62> >string ] unit-test
