USING: kernel tools.test ui.gadgets.worlds ui.tools.debugger ;
IN: ui.tools.debugger.tests


{ f } [
    f <world-attributes> <world> world-error boa error-in-debugger?
] unit-test
