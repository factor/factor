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
    "Hello world" <namespace> [ html-attr-string ] bind
] unit-test

[ "<b>Hello world</b>" ]
[
    "Hello world"
    <namespace> [ t "bold" set ] extend
    [ html-attr-string ] bind
] unit-test

[ "<i>Hello world</i>" ]
[
    "Hello world" <namespace> [ t "italics" set ] extend
    [ html-attr-string ] bind
] unit-test

[ "<font color=\"#ff00ff\">Hello world</font>" ]
[
    "Hello world" <namespace> [ [ 255 0 255 ] "fg" set ] extend
    [ html-attr-string ] bind
] unit-test
