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

[ "<span style=\"color: #ff00ff; font-family: Monospaced; \">car</span>" ]
[
    "car"
    [ [ "fg" 255 0 255 ] [ "font" | "Monospaced" ] ]
    span-tag
] unit-test
