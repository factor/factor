! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: modern.html multiline tools.test ;
IN: modern.html.tests

[
    [[ <html>]] string>html
] [ unmatched-open-tags-error? ] must-fail-with

[
    [[ <html><body></html>]] string>html
] [ unmatched-open-tags-error? ] must-fail-with

[
    [[ <html><body><html/>]] string>html
] [ unmatched-open-tags-error? ] must-fail-with

[
    [[ </html>]] string>html
] [ unmatched-closing-tag-error? ] must-fail-with

[
    [[ <html></html123>]] string>html
] [ unmatched-closing-tag-error? ] must-fail-with

{ [[ <html><head>omg</head><body><asdf a b c="d"><a/></asdf></body></html>]] } [
    [[ <html><head>omg</head><body><asdf a b c="d" > <a/></asdf></body></html>]] string>html html>string
] unit-test

[
    [[ <html><head>omg<body></body></html>]] string>html html>string
] [ unmatched-open-tags-error? ] must-fail-with

{ [[ <!-- omg omg -->]] }
[ [[ <!-- omg omg -->]] string>html html>string ] unit-test