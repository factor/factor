USING: accessors namespaces sequences tools.test ui.commands
ui.gadgets ui.gadgets.toolbar ;
IN: ui.gadgets.toolbar.tests

TUPLE: foo-gadget ;

: com-foo-a ( -- ) ;

: com-foo-b ( -- ) ;

\ foo-gadget "toolbar" f {
    { f com-foo-a }
    { f com-foo-b }
} define-command-map

T{ foo-gadget } <toolbar> "t" set

{ 2 } [ "t" get children>> length ] unit-test
{ "Foo A" } [ "t" get gadget-child gadget-child string>> ] unit-test


