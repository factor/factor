IN: temporary
USING: ui.commands ui.gadgets.buttons ui.gadgets.labels
ui.gadgets tools.test namespaces sequences kernel ;

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
