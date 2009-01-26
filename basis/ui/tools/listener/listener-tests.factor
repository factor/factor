USING: continuations documents
ui.tools.listener hashtables kernel namespaces parser sequences
tools.test ui.commands ui.gadgets ui.gadgets.editors
ui.gadgets.panes vocabs words tools.test.ui slots.private
threads arrays generic threads accessors listener math
calendar concurrency.promises io ui.tools.common ;
IN: ui.tools.listener.tests

\ <interactor> must-infer

[
    [ ] [ <pane> <pane-stream> <interactor> "interactor" set ] unit-test

    [ ] [ "interactor" get register-self ] unit-test

    [ ] [ "[ 1 2 3" "interactor" get set-editor-string ] unit-test

    [ ] [ <promise> "promise" set ] unit-test

    [
        self "interactor" get (>>thread)
        "interactor" get stream-read-quot "promise" get fulfill
    ] "Interactor test" spawn drop

    ! This should not throw an exception
    [ ] [ "interactor" get evaluate-input ] unit-test

    [ ] [ [ "interactor" get interactor-busy? ] [ yield ] [ ] while ] unit-test

    [ ] [ "[ 1 2 3 ]" "interactor" get set-editor-string ] unit-test

    [ ] [ "interactor" get evaluate-input ] unit-test

    [ [ [ 1 2 3 ] ] ] [ "promise" get 5 seconds ?promise-timeout ] unit-test
] with-interactive-vocabs

! Hang
[ ] [ <pane> <pane-stream> <interactor> "interactor" set ] unit-test

[ ] [ [ "interactor" get stream-read-quot drop ] "A" spawn drop ] unit-test

[ ] [ [ "interactor" get stream-read-quot drop ] "B" spawn drop ] unit-test

[ ] [ 1 seconds sleep ] unit-test

[ ] [ "interactor" get interactor-eof ] unit-test

[ ] [ <pane> <pane-stream> <interactor> "interactor" set ] unit-test

: text "Hello world.\nThis is a test." ;

[ ] [ text "interactor" get set-editor-string ] unit-test

[ ] [ <promise> "promise" set ] unit-test

[ ] [
    [
        "interactor" get register-self
        "interactor" get contents "promise" get fulfill
    ] in-thread
] unit-test

[ ] [ 100 milliseconds sleep ] unit-test

[ ] [ "interactor" get evaluate-input ] unit-test

[ ] [ 100 milliseconds sleep ] unit-test
    
[ ] [ "interactor" get interactor-eof ] unit-test

[ t ] [ "promise" get 2 seconds ?promise-timeout text = ] unit-test

[ ] [ <pane> <pane-stream> <interactor> "interactor" set ] unit-test

[ ] [ text "interactor" get set-editor-string ] unit-test

[ ] [ <promise> "promise" set ] unit-test

[ ] [
    [
        "interactor" get register-self
        "interactor" get stream-read1 "promise" get fulfill
    ] in-thread
] unit-test

[ ] [ 100 milliseconds sleep ] unit-test

[ ] [ "interactor" get evaluate-input ] unit-test

[ CHAR: H ] [ "promise" get 2 seconds ?promise-timeout ] unit-test

[ f ] [ "word" source-editor command-map commands>> empty? ] unit-test

[ ] [ <listener-gadget> [ ] with-grafted-gadget ] unit-test

[ ] [ <listener-gadget> "listener" set ] unit-test

"listener" get [
    <pane> <interactor> "i" set

    [ t ] [ "i" get interactor? ] unit-test

    [ ] [ "SYMBOL:" "i" get set-editor-string ] unit-test

    [ ] [
        "i" get [ { "SYMBOL:" } parse-lines ] [ go-to-error ] recover
    ] unit-test
    
    [ t ] [
        "i" get model>> doc-end
        "i" get editor-caret =
    ] unit-test

    ! Race condition discovered by SimonRC
    [ ] [
        [
            "listener" get input>>
            [ stream-read-quot drop ]
            [ stream-read-quot drop ] bi
        ] "OH, HAI" spawn drop
    ] unit-test

    [ ] [ "listener" get clear-output ] unit-test

    [ ] [ "listener" get restart-listener ] unit-test

    [ ] [ 1 seconds sleep ] unit-test

    [ ] [ "listener" get com-end ] unit-test
] with-grafted-gadget

[ ] [ \ + <pane> <interactor> interactor-use use-if-necessary ] unit-test

[ ] [ <listener-gadget> "l" set ] unit-test
[ ] [ "l" get com-scroll-up ] unit-test
[ ] [ "l" get com-scroll-down ] unit-test
[ ] [ "l" get hide-popup ] unit-test
[ ] [ <gadget> "l" get show-popup ] unit-test
[ ] [ "l" get hide-popup ] unit-test

[ ] [
    <gadget> "l" get show-popup
    <gadget> "l" get show-popup
    "l" get hide-popup
] unit-test