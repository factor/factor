IN: scratchpad
USE: namespaces
USE: line-editor
USE: test
USE: strings
USE: kernel
USE: prettyprint

<line-editor> "editor" set

[ "Hello world" ] [
    "Hello world" 0 "editor" get [ line-insert ] bind
    "editor" get [ line-text get ] bind
] unit-test

[ t ] [
    "editor" get [ caret get ] bind
    "Hello world" string-length =
] unit-test

[ "Hello, crazy world" ] [
    "editor" get [ 0 caret set ] bind
    ", crazy" 5 "editor" get [ line-insert ] bind
    "editor" get [ line-text get ] bind
] unit-test

[ 0 ] [ "editor" get [ caret get ] bind ] unit-test

[ "Hello, crazy world" ] [
    "editor" get [ 5 caret set "Hello world" line-text set ] bind
    ", crazy" 5 "editor" get [ line-insert ] bind
    "editor" get [ line-text get ] bind
] unit-test

[ "Hello, crazy" ] [
    "editor" get [ caret get line-text get string-head ] bind
] unit-test

[ 0 ]
[
    [
        0 caret set
        3 2 caret-remove
        caret get
    ] with-scope
] unit-test

[ 3 ]
[
    [
        4 caret set
        3 6 caret-remove
        caret get
    ] with-scope
] unit-test

[ 5 ]
[
    [
        8 caret set
        3 3 caret-remove
        caret get
    ] with-scope
] unit-test

[ "Hellorld" ]
[
    "editor" get [ 0 caret set "Hello world" line-text set ] bind
    4 3 "editor" get [ line-remove ] bind
    "editor" get [ line-text get ] bind
] unit-test
