USING: accessors colors.constants sequences tools.test
ui.gadgets ui.gadgets.labeled ;
IN: ui.gadgets.labeled.tests

{ t } [
    <gadget> "Hey" color: blue <labeled-gadget>
    content>> gadget?
] unit-test
