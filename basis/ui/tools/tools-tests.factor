USING: ui.tools ui.tools.interactor ui.tools.listener
ui.tools.search ui.tools.workspace kernel models namespaces
sequences tools.test ui.gadgets ui.gadgets.buttons
ui.gadgets.labelled ui.gadgets.presentations
ui.gadgets.menus ui.gadgets.scrollers vocabs tools.test.ui ui accessors ;
IN: ui.tools.tests

[ f ]
[
    <gadget> 0 <model> >>model <workspace-tabs> children>> empty?
] unit-test

[ ] [ <workspace> "w" set ] unit-test
[ ] [ "w" get com-scroll-up ] unit-test
[ ] [ "w" get com-scroll-down ] unit-test
[ t ] [
    "w" get book>> children>>
    [ tool-scroller ] map sift [ scroller? ] all?
] unit-test
[ ] [ "w" get hide-popup ] unit-test
[ ] [ <gadget> "w" get show-popup ] unit-test
[ ] [ "w" get hide-popup ] unit-test

[ ] [
    <gadget> "w" get show-popup
    <gadget> "w" get show-popup
    "w" get hide-popup
] unit-test

[ ] [ <workspace> [ ] with-grafted-gadget ] unit-test

"w" get [

    [ ] [ "w" get "kernel" vocab show-vocab-words ] unit-test

    [ ] [ notify-queued ] unit-test

    [ ] [ "w" get popup>> content>>
    list>> gadget-child "p" set ] unit-test

    [ t ] [ "p" get presentation? ] unit-test

    [ ] [
        "p" get [ object>> ] [ dup hook>> curry ] bi
        <operations-menu> gadget-child gadget-child "c" set
    ] unit-test

    [ ] [ notify-queued ] unit-test

    [ t ] [ "c" get button? ] unit-test

    [ ] [
        "w" get listener>> input>>
        3 handle-parse-error
    ] unit-test

    [ ] [ notify-queued ] unit-test
] with-grafted-gadget
