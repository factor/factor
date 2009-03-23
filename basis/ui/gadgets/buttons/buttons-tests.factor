USING: ui.commands ui.gadgets.buttons ui.gadgets.labels
ui.gadgets tools.test namespaces sequences kernel models
accessors ;
IN: ui.gadgets.buttons.tests

TUPLE: foo-gadget ;

: com-foo-a ( -- ) ;

: com-foo-b ( -- ) ;

\ foo-gadget "toolbar" f {
    { f com-foo-a }
    { f com-foo-b }
} define-command-map

T{ foo-gadget } <toolbar> "t" set

[ 2 ] [ "t" get children>> length ] unit-test
[ "Foo A" ] [ "t" get gadget-child gadget-child string>> ] unit-test

[ ] [
    2 <model> {
        { 0 "atheist" }
        { 1 "christian" }
        { 2 "muslim" }
        { 3 "jewish" }
    } <radio-buttons> "religion" set
] unit-test

\ <radio-buttons> must-infer

\ <checkbox> must-infer

[ 0 ] [
    "religion" get gadget-child value>>
] unit-test

[ 2 ] [
    "religion" get gadget-child control-value
] unit-test
