USING: html.parser kernel tools.test ;
IN: temporary

[
    V{ T{ tag f "html" H{ } f f f } }
] [ "<html>" parse-html ] unit-test

[
    V{ T{ tag f "html" H{ } f f t } }
] [ "</html>" parse-html ] unit-test

[
    V{ T{ tag f "a" H{ { "href" "http://factorcode.org/" } } f f f } }
] [ "<a href=\"http://factorcode.org/\">" parse-html ] unit-test

[
    V{ T{ tag f "a" H{ { "href" "http://factorcode.org/" } } f f f } }
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
        } f f f }
}
] [ "<a   href  =    \"http://factorcode.org/\"    foo   =  bar baz='quux'a=pirsqd  >" parse-html ] unit-test

[
V{
    T{ tag f "html" H{ } f f f }
    T{ tag f "head" H{ } f f f }
    T{ tag f "head" H{ } f f t }
    T{ tag f "html" H{ } f f t }
}
] [ "<html<head</head</html" parse-html ] unit-test

[
V{
    T{ tag f "head" H{ } f f f }
    T{ tag f "title" H{ } f f f }
    T{ tag f text f "Spagna" f f }
    T{ tag f "title" H{ } f f t }
    T{ tag f "head" H{ } f f t }
}
] [ "<head<title>Spagna</title></head" parse-html ] unit-test
