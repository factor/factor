IN: ui.gadgets.slots.tests
USING: assocs ui.gadgets.slots tools.test refs ;

{ t } [ [ ] [ ] { { 1 1 } { 2 2 } { 3 3 } } 2 <value-ref> <slot-editor> slot-editor? ] unit-test
