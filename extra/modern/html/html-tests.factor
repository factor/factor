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

{ "<div><div><a/><b/><c/></div></div>" }
[ "<div> <div>  <a/> <b/> <c/> </div> </div>" string>html html>string ] unit-test

{ "<?xml version='1.0'?>" }
[ [[ <?xml version='1.0'?> ]] string>html html>string ] unit-test

{ "<?xml version='1.0'?>" }
[ [[ <?xml version='1.0' ?> ]] string>html html>string ] unit-test

{
    V{
        T{ doctype
            { open "<!DOCTYPE" }
            { close ">" }
            { values
                V{
                    "plist"
                    "PUBLIC"
                    T{ dquote
                        { payload "-//Apple//DTD PLIST 1.0//EN" }
                    }
                    T{ dquote
                        { payload
                            "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
                        }
                    }
                }
            }
        }
    }
} [
    [[ <!DOCTYPE plist PUBLIC
    "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    ]]
    string>html
] unit-test

{
    V{ T{ comment { open "<!--" } { payload " comment " } { close "-->" } } }
} [ [[ <!-- comment --> ]] string>html ] unit-test