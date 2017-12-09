USING: accessors colors.constants sequences tools.test
ui.gadgets ui.gadgets.labeled ;
IN: ui.gadgets.labeled.tests

{ t } [
    <gadget> "Hey" COLOR: blue <labeled-gadget>
    content>> gadget?
] unit-test
