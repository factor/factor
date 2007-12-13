USING: ui.tools ui.tools.interactor ui.tools.listener
ui.tools.search ui.tools.workspace kernel models namespaces
sequences timers tools.test ui.gadgets ui.gadgets.buttons
ui.gadgets.labelled ui.gadgets.presentations
ui.gadgets.scrollers vocabs tools.test.ui ui ;
IN: temporary

[
    [ f ] [
        0 <model> <gadget> [ set-gadget-model ] keep gadget set
        <workspace-tabs> gadget-children empty?
    ] unit-test
] with-scope

timers get [ init-timers ] unless

[ ] [ <workspace> "w" set ] unit-test
[ ] [ "w" get com-scroll-up ] unit-test
[ ] [ "w" get com-scroll-down ] unit-test
[ t ] [
    "w" get workspace-book gadget-children
    [ tool-scroller ] map [ ] subset [ scroller? ] all?
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

    [ ] [ "w" get workspace-popup closable-gadget-content
    live-search-list gadget-child "p" set ] unit-test

    [ t ] [ "p" get presentation? ] unit-test

    [ ] [ "p" get <operations-menu> gadget-child gadget-child "c" set ] unit-test

    [ ] [ notify-queued ] unit-test

    [ t ] [ "c" get button? ] unit-test

    [ ] [
        "w" get workspace-listener listener-gadget-input
        3 handle-parse-error
    ] unit-test

    [ ] [ notify-queued ] unit-test
] with-grafted-gadget
