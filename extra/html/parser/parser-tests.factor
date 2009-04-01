USING: html.parser kernel tools.test ;
IN: html.parser.tests

[
    V{ T{ tag f "html" H{ } f f } }
] [ "<html>" parse-html ] unit-test

[
    V{ T{ tag f "html" H{ } f t } }
] [ "</html>" parse-html ] unit-test

[
    V{ T{ tag f "a" H{ { "href" "http://factorcode.org/" } } f f } }
] [ "<a href=\"http://factorcode.org/\">" parse-html ] unit-test

[
    V{ T{ tag f "a" H{ { "href" "http://factorcode.org/" } } f f } }
] [ "<a   href  =  \"http://factorcode.org/\"   >" parse-html ] unit-test

[
V{
    T{
        tag
        f
        "a"
        H{ { "baz" "\"quux\"" } { "foo" "bar's" } }
        f
        f
    }
}
] [ "<a   foo=\"bar's\" baz='\"quux\"'  >" parse-html ] unit-test

[
V{
    T{ tag f "a"
        H{
            { "a" "pirsqd" }
            { "foo" "bar" }
            { "href" "http://factorcode.org/" }
            { "baz" "quux" }
        } f f }
}
] [ "<a   href  =    \"http://factorcode.org/\"    foo   =  bar baz='quux'a=pirsqd  >" parse-html ] unit-test

[
V{
    T{ tag f "a"
        H{
            { "a" "pirsqd" }
            { "foo" "bar" }
            { "href" "http://factorcode.org/" }
            { "baz" "quux" }
            { "nofollow" "nofollow" }
        } f f }
}
] [ "<a   href  =    \"http://factorcode.org/\"    nofollow  foo   =  bar baz='quux'a=pirsqd  >" parse-html ] unit-test

[
V{
    T{ tag f "html" H{ } f f }
    T{ tag f "head" H{ } f f }
    T{ tag f "head" H{ } f t }
    T{ tag f "html" H{ } f t }
}
] [ "<html<head</head</html" parse-html ] unit-test

[
V{
    T{ tag f "head" H{ } f f }
    T{ tag f "title" H{ } f f }
    T{ tag f text f "Spagna" f }
    T{ tag f "title" H{ } f t }
    T{ tag f "head" H{ } f t }
}
] [ "<head<title>Spagna</title></head" parse-html ] unit-test
