USING: accessors colors.constants sequences tools.test
ui.gadgets ui.gadgets.labeled ;
IN: ui.gadgets.labeled.tests

{ t } [
    <gadget> "Hey" <labeled-gadget> content>> gadget?
] unit-test
