IN: temporary
USING: tools.test tools.test.ui ui.tools.browser
tools.test.inference ui.private ;

{ 0 1 } [ <browser-gadget> ] unit-test-effect
[ ] [ <browser-gadget> [ ] with-grafted-gadget ] unit-test
