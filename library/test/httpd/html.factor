IN: scratchpad
USE: html
USE: namespaces
USE: stdio
USE: streams
USE: strings
USE: test

[
    "&lt;html&gt;&amp;&apos;sgml&apos;"
] [ "<html>&'sgml'" chars>entities ] unit-test

[ "Hello world" ]
[
    "Hello world" f html-attr-string
] unit-test

[ "<b>Hello world</b>" ]
[
    "Hello world"
    [ [ "bold" | t ] ]
    html-attr-string
] unit-test

[ "<i>Hello world</i>" ]
[
    "Hello world"
    [ [ "italics" | t ] ]
    html-attr-string
] unit-test

[ "<font color=\"#ff00ff\">Hello world</font>" ]
[
    "Hello world"
    [ [ "fg" 255 0 255 ] ]
    html-attr-string
] unit-test
