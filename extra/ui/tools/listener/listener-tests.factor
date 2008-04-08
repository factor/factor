USING: continuations documents ui.tools.interactor
ui.tools.listener hashtables kernel namespaces parser sequences
tools.test ui.commands ui.gadgets ui.gadgets.editors
ui.gadgets.panes vocabs words tools.test.ui slots.private
threads arrays generic ;
IN: ui.tools.listener.tests

[ f ] [ "word" source-editor command-map empty? ] unit-test

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
        "i" get gadget-model doc-end
        "i" get editor-caret* =
    ] unit-test
] with-grafted-gadget
