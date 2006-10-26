IN: temporary
USING: gadgets-labels gadgets namespaces test ;

"Hey" <label> "Foo" <titled-gadget> "t" set

[ t ] [ "t" get focusable-child label? ] unit-test
[ "Foo" ] [ "t" get gadget-title ] unit-test
