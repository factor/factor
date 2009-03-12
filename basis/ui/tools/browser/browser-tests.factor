IN: ui.tools.browser.tests
USING: tools.test tools.test.ui ui.tools.browser math ;

\ <browser-gadget> must-infer
[ ] [ \ + <browser-gadget> [ ] with-grafted-gadget ] unit-test
