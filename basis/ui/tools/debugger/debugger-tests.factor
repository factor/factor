USING: kernel tools.test ui.gadgets.worlds ui.tools.debugger ;

{ f } [
    f <world-attributes> <world> world-error boa error-in-debugger?
] unit-test
