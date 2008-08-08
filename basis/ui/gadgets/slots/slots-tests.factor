IN: ui.gadgets.slots.tests
USING: assocs ui.gadgets.slots tools.test refs ;

\ <editable-slot> must-infer

[ t ] [ { 1 2 3 } 2 <value-ref> <slot-editor> slot-editor? ] unit-test
