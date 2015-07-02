USING: http http.parsers tools.test ;
IN: http.parsers.tests

{ { } } [ "" parse-cookie ] unit-test
{ { } } [ "" parse-set-cookie ] unit-test

! Make sure that totally invalid cookies don't confuse us
{ { } } [ "hello world; how are you" parse-cookie ] unit-test

{ { T{ cookie { name "__s" } { value "12345567" } } } }
[ "__s=12345567" parse-cookie ]
unit-test

{ { T{ cookie { name "CaseSensitive" } { value "aBc" } } } }
[ "CaseSensitive=aBc" parse-cookie ]
unit-test

{ { T{ cookie { name "__s" } { value "12345567" } } } }
[ "__s=12345567;" parse-cookie ]
unit-test
