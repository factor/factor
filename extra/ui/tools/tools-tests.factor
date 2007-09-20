USING: ui.tools ui.tools.interactor ui.tools.listener
ui.tools.search ui.tools.workspace kernel models namespaces
sequences timers tools.test ui.gadgets ui.gadgets.buttons
ui.gadgets.controls ui.gadgets.labelled ui.gadgets.presentations
ui.gadgets.scrollers vocabs ;
IN: temporary

[
    [ f ] [
        0 <model> <gadget> [ 2drop ] <control> gadget set
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

[ ] [
    <workspace> "w" set
    "w" get graft
    "w" get "kernel" vocab show-vocab-words
] unit-test

"w" get workspace-popup closable-gadget-content
live-search-list gadget-child "p" set

[ t ] [ "p" get presentation? ] unit-test

"p" get <operations-menu> gadget-child gadget-child "c" set

[ t ] [ "c" get button? ] unit-test

[ ] [
    "w" get workspace-listener listener-gadget-input
    3 handle-parse-error
] unit-test

[ ] [ "w" get ungraft ] unit-test
