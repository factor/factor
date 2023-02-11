! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: html.parser html.parser.analyzer kernel math sequences tools.test ;

{ 0 3 }
[ 1 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test

{ 2 7 }
[ 3 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test

{ 3 9 }
[ 3 1 { 3 5 7 9 11 } [ odd? ] find-nth-from ] unit-test

{ 4 11 }
[ 1 { 3 5 7 9 11 } [ odd? ] find-last-nth ] unit-test

{ 2 7 }
[ 3 { 3 5 7 9 11 } [ odd? ] find-last-nth ] unit-test

{ 0 3 }
[ 1 2 { 3 5 7 9 11 } [ odd? ] find-last-nth-from ] unit-test


[ 0 { 3 5 7 9 11 } [ odd? ] find-nth ]
[ undefined-find-nth? ] must-fail-with

[ 0 { 3 5 7 9 11 } [ odd? ] find-last-nth ]
[ undefined-find-nth? ] must-fail-with

{ V{
    T{ tag f text f "foo" f }
}
} [
    "<!DOCTYPE html><html><head><title>foo</title></head></html>" parse-html
    "title" find-between-first
] unit-test

{ V{
    T{ tag f "p" H{ } f f }
    T{ tag f text f "para" f }
    T{ tag f "p" H{ } f t }
}
} [
    "<body><div><p>para</p></div></body>" parse-html "div" find-between-first
] unit-test

{ V{
    T{ tag f "div" H{ { "class" "foo" } } f f }
    T{ tag f "p" H{ } f f }
    T{ tag f text f "para" f }
    T{ tag f "p" H{ } f t }
    T{ tag f "div" H{ } f t }
}
} [
    "<body><div class=\"foo\"><p>para</p></div></body>" parse-html
    "foo" find-by-class-between
] unit-test

{ V{
    T{ tag f "div" H{ { "class" "foo" } } f f }
    T{ tag f "div" H{ } f f }
    T{ tag f "p" H{ } f f }
    T{ tag f text f "para" f }
    T{ tag f "p" H{ } f t }
    T{ tag f "div" H{ } f t }
    T{ tag f "div" H{ } f t }
}
} [
    "<body><div class=\"foo\"><div><p>para</p></div></div></body>" parse-html
    "foo" find-by-class-between
] unit-test

{ t } [
    T{ tag { name "f" } { attributes H{ { "class" "a b c" } } } }
    { "a" "b" "c" } [ html-class? ] with all?
] unit-test

{
    V{
        T{ tag
           { name "div" }
           { attributes H{ { "class" "foo and more" } } }
        }
        T{ tag { name "div" } { attributes H{ } } { closing? t } }
    }
} [ "<div class=\"foo and more\"></div>" parse-html
    "foo" find-by-class-between
] unit-test

{
    0
    T{ tag { name "div" } { attributes H{ { "class" "foo bar" } } } }
} [
    "<div class=\"foo bar\"></div>" parse-html "bar" find-by-class
] unit-test
