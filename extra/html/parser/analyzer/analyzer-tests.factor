! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: html.parser html.parser.analyzer math tools.test ;
IN: html.parser.analyzer.tests

[ 0 3 ]
[ 1 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test

[ 2 7 ]
[ 3 { 3 5 7 9 11 } [ odd? ] find-nth ] unit-test

[ 3 9 ]
[ 3 1 { 3 5 7 9 11 } [ odd? ] find-nth-from ] unit-test

[ 4 11 ]
[ 1 { 3 5 7 9 11 } [ odd? ] find-last-nth ] unit-test

[ 2 7 ]
[ 3 { 3 5 7 9 11 } [ odd? ] find-last-nth ] unit-test

[ 0 3 ]
[ 1 2 { 3 5 7 9 11 } [ odd? ] find-last-nth-from ] unit-test


[ 0 { 3 5 7 9 11 } [ odd? ] find-nth ]
[ undefined-find-nth? ] must-fail-with

[ 0 { 3 5 7 9 11 } [ odd? ] find-last-nth ]
[ undefined-find-nth? ] must-fail-with

[ V{
    T{ tag f text f "foo" f }
}
] [
    "<html><head><title>foo</title></head></html>" parse-html
    "title" find-between-first
] unit-test

[ V{
    T{ tag f "p" H{ } f f }
    T{ tag f text f "para" f }
    T{ tag f "p" H{ } f t }
}
] [
    "<body><div><p>para</p></div></body>" parse-html "div" find-between-first
] unit-test

[ V{
    T{ tag f "div" H{ { "class" "foo" } } f f }
    T{ tag f "p" H{ } f f }
    T{ tag f text f "para" f }
    T{ tag f "p" H{ } f t }
    T{ tag f "div" H{ } f t }
}
] [
    "<body><div class=\"foo\"><p>para</p></div></body>" parse-html
    "foo" find-by-class-between
] unit-test

[ V{
    T{ tag f "div" H{ { "class" "foo" } } f f }
    T{ tag f "div" H{ } f f }
    T{ tag f "p" H{ } f f }
    T{ tag f text f "para" f }
    T{ tag f "p" H{ } f t }
    T{ tag f "div" H{ } f t }
    T{ tag f "div" H{ } f t }
}
] [
    "<body><div class=\"foo\"><div><p>para</p></div></div></body>" parse-html
    "foo" find-by-class-between
] unit-test
