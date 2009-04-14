IN: ui.tools.browser.tests
USING: tools.test ui.gadgets.debug ui.tools.browser math ;

\ <browser-gadget> must-infer
[ ] [ \ + <browser-gadget> [ ] with-grafted-gadget ] unit-test
