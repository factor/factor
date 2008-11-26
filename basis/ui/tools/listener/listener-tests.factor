USING: continuations documents ui.tools.interactor
ui.tools.listener hashtables kernel namespaces parser sequences
tools.test ui.commands ui.gadgets ui.gadgets.editors
ui.gadgets.panes vocabs words tools.test.ui slots.private
threads arrays generic threads accessors listener math
calendar ;
IN: ui.tools.listener.tests

[ f ] [ "word" source-editor command-map commands>> empty? ] unit-test

[ ] [ <listener-gadget> [ ] with-grafted-gadget ] unit-test

[ ] [ <listener-gadget> "listener" set ] unit-test

"listener" get [
    [ "dup" ] [
        \ dup word-completion-string
    ] unit-test

    [ "equal?" ]
    [ \ array \ equal? method word-completion-string ] unit-test

    <pane> <interactor> "i" set

    [ t ] [ "i" get interactor? ] unit-test

    [ ] [ "SYMBOL:" "i" get set-editor-string ] unit-test

    [ ] [
        "i" get [ { "SYMBOL:" } parse-lines ] [ go-to-error ] recover
    ] unit-test
    
    [ t ] [
        "i" get model>> doc-end
        "i" get editor-caret* =
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
