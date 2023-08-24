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

{ { T{ cookie { name "a:b" } { value "c" } } } }
[ "a:b=c;" parse-cookie ]
unit-test

{ { T{ cookie { name "d" } { value "[e]" } } } }
[ "d=[e];" parse-cookie ]
unit-test

! Don't stop parsing on just one bad cookie
{
    {
        T{ cookie { name "d" } { value "[e]" } }
        T{ cookie { name "g" } { value "h" } }
    }
} [ "d=[e]; a: ; g=h;" parse-cookie ] unit-test

! Don't stop parsing on just one bad cookie
{
    {
        T{ cookie { name "d" } { value "[e]" } }
        T{ cookie { name "g" } { value "h" } }
    }
} [ "d=[e]; a: ; g=h;" parse-cookie ] unit-test

! Add some cookies with extra features
{
    V{ "set-cookie" "mykey=myvalue; SameSite=Strict" }
}
[ "Set-Cookie: mykey=myvalue; SameSite=Strict" parse-header-line ] unit-test

{
    V{
        "set-cookie"
        "id=a3fWa; Expires=Thu, 21 Oct 2021 07:28:00 GMT; Secure; HttpOnly"
    }
}
[ "Set-Cookie: id=a3fWa; Expires=Thu, 21 Oct 2021 07:28:00 GMT; Secure; HttpOnly" parse-header-line ] unit-test

! python allowed characters in key name
{
    { T{ cookie { name "!#$%&'*+-.^_`|~:abc" } { value "def" } } }
} [
    "!#$%&'*+-.^_`|~:abc=def;" parse-cookie
] unit-test

