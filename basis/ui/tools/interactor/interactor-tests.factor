IN: ui.tools.interactor.tests
USING: ui.tools.interactor ui.gadgets.panes namespaces
ui.gadgets.editors concurrency.promises threads listener
tools.test kernel calendar parser accessors calendar io ;

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

    [ ] [ [ "interactor" get interactor-busy? ] [ yield ] while ] unit-test

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
