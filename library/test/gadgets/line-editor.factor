IN: temporary
USING: kernel line-editor namespaces sequences strings test ;

<line-editor> "editor" set

[ 14 ] [ 4 5 5 10 (point-update) ] unit-test

[ 10 ] [ 4 15 15 10 (point-update) ] unit-test

[ 6 ] [ 0 5 9 10 (point-update) ] unit-test

[ 5 ] [ 0 5 13 10 (point-update) ] unit-test

[ 10 ] [ 0 18 23 10 (point-update) ] unit-test

[ 0 ] [ 0 0 10 10 (point-update) ] unit-test

[ "Hello world" ] [
    "Hello world" 0 0 "editor" get [ line-replace ] bind
    "editor" get [ line-text get ] bind
] unit-test

[ t ] [
    "editor" get [ caret-pos ] bind
    "Hello world" length =
] unit-test

[ "Hello, crazy world" ] [
    "editor" get [ 0 set-caret-pos ] bind
    ", crazy" 5 5 "editor" get [ line-replace ] bind
    "editor" get [ line-text get ] bind
] unit-test

[ 0 ] [ "editor" get [ caret-pos ] bind ] unit-test

[ "Hello, crazy world" ] [
    "editor" get [ 5 set-caret-pos "Hello world" line-text set ] bind
    ", crazy" 5 5 "editor" get [ line-replace ] bind
    "editor" get [ line-text get ] bind
] unit-test

[ "Hello, crazy" ] [
    "editor" get [ caret-pos line-text get head ] bind
] unit-test

[ "Hellorld" ]
[
    "editor" get [ 0 set-caret-pos "Hello world" line-text set ] bind
    4 7 "editor" get [ line-remove ] bind
    "editor" get [ line-text get ] bind
] unit-test

[ 0 "" ]
[
    "editor" get [ "hello world" set-line-text ] bind
    "editor" get [ 0 line-length line-remove ] bind
    "editor" get [ caret-pos line-text get ] bind
] unit-test
