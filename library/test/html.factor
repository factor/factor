IN: scratchpad
USE: compiler
USE: html
USE: namespaces
USE: stdio
USE: streams
USE: strings
USE: test

[ [ 1 1 0 0 ] ] [ [ chars>entities ] ] [ balance>list ] test-word
[
    "&lt;html&gt;&amp;&apos;sgml&apos;"
] [ "<html>&'sgml'" ] [ chars>entities ] test-word

[ [ 1 1 0 0 ] ] [ [ html-attr-string ] ] [ balance>list ] test-word

[ "Hello world" ]
[ "Hello world" <namespace> ]
[ [ html-attr-string ] bind ] test-word

[ "<b>Hello world</b>" ]
[ "Hello world" <namespace> [ t "bold" set ] extend ]
[ [ html-attr-string ] bind ] test-word

[ "<i>Hello world</i>" ]
[ "Hello world" <namespace> [ t "italics" set ] extend ]
[ [ html-attr-string ] bind ] test-word

[ "<font color=\"#ff00ff\">Hello world</font>" ]
[ "Hello world" <namespace> [ [ 255 0 255 ] "fg" set ] extend ]
[ [ html-attr-string ] bind ] test-word
