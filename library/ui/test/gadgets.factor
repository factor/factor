IN: temporary
USING: gadgets test ;

TUPLE: fooey ;

[ ] [ <gadget> <fooey> set-gadget-delegate ] unit-test
[ ] [ f <fooey> set-gadget-delegate ] unit-test
