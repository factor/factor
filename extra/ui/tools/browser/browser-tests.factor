IN: temporary
USING: tools.test tools.test.ui ui.tools.browser
tools.test.inference ;

\ <browser-gadget> must-infer
[ ] [ <browser-gadget> [ ] with-grafted-gadget ] unit-test
