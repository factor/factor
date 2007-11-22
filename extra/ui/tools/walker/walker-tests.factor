USING: arrays continuations ui.tools.listener ui.tools.walker
ui.tools.workspace inspector kernel namespaces sequences threads
listener tools.test ui ui.gadgets ui.gadgets.worlds ui.private
ui.gadgets.packs vectors ui.tools tools.interpreter
tools.interpreter.debug tools.test.inference tools.test.ui ;
IN: temporary

{ 0 1 } [ <walker> ] unit-test-effect

[ ] [ <walker> "walker" set ] unit-test

"walker" get [
    ! Make sure the toolbar buttons don't throw if we're
    ! not actually walking.

    [ ] [ "walker" get com-step ] unit-test
    [ ] [ "walker" get com-into ] unit-test
    [ ] [ "walker" get com-out ] unit-test
    [ ] [ "walker" get com-back ] unit-test
    [ ] [ "walker" get com-inspect ] unit-test
    [ ] [ "walker" get reset-walker ] unit-test
    [ ] [ "walker" get com-continue ] unit-test
] with-grafted-gadget

: <test-world> ( gadget -- world )
    [ gadget, ] make-pile "Hi" f <world> ;

f <workspace> dup [
    [ <test-world> 2array 1vector windows set ] keep

    "ok" off

    [
        workspace-listener
        listener-gadget-input
        "ok" on
        parse-interactive
        "c" get continue-with
    ] in-thread drop

    [ t ] [ "ok" get ] unit-test

    [ ] [ walker get-tool "w" set ] unit-test
    continuation "c" set

    [ ] [ "c" get "w" get call-tool* ] unit-test

    [ ] [
        [ "c" set f ] callcc1
        [ "q" set ] [ "w" get com-inspect stop ] if*
    ] unit-test

    [ t ] [
        "q" get dup first continuation?
        swap second \ inspect eq? and
    ] unit-test
] with-grafted-gadget

[
    f <workspace> dup [
        <test-world> 2array 1vector windows set

        [ ] [
            [ 2 3 break 4 ] quot>cont f swap 2array walker call-tool
        ] unit-test

        [ ] [ walker get-tool com-continue ] unit-test

        [ ] [ yield ] unit-test

        [ t ] [ walker get-tool walker-active? ] unit-test

        [ ] [ "walker" get com-continue ] unit-test

        [ ] [ "walker" get com-continue ] unit-test

        [ ] [ "walker" get com-continue ] unit-test
    ] with-grafted-gadget
] with-scope
