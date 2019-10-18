IN: temporary
USING: ui.commands ui.gadgets.buttons ui.gadgets.labels
ui.gadgets tools.test namespaces sequences kernel models
tools.test.inference ;

TUPLE: foo-gadget ;

: com-foo-a ;

: com-foo-b ;

\ foo-gadget "toolbar" f {
    { f com-foo-a }
    { f com-foo-b }
} define-command-map

T{ foo-gadget } <toolbar> "t" set

[ 2 ] [ "t" get gadget-children length ] unit-test
[ "Foo a" ] [ "t" get gadget-child gadget-child label-string ] unit-test

[ ] [
    2 <model> {
        { 0 "atheist" }
        { 1 "christian" }
        { 2 "muslim" }
        { 3 "jewish" }
    } <radio-buttons> "religion" set
] unit-test

{ 2 1 } [ <radio-buttons> ] unit-test-effect

{ 2 1 } [ <toggle-buttons> ] unit-test-effect

{ 2 1 } [ <checkbox> ] unit-test-effect

[ 0 ] [
    "religion" get gadget-child radio-control-value
] unit-test

[ 2 ] [
    "religion" get gadget-child control-value
] unit-test
