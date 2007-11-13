USING: continuations documents ui.tools.interactor
ui.tools.listener hashtables kernel namespaces parser sequences
timers tools.test ui.commands ui.gadgets.editors
ui.gadgets.panes vocabs words ;
IN: temporary

timers [ init-timers ] unless

[ f ] [ "word" source-editor command-map empty? ] unit-test

<listener-gadget> "listener" set

{ "kernel" } [ vocab-words ] map use associate
"listener" get listener-gadget-input set-interactor-vars

[ "dup" ] [ \ dup "listener" get word-completion-string ] unit-test

[ "USE: words word-name" ]
[ \ word-name "listener" get word-completion-string ] unit-test

<pane> <interactor> "i" set
H{ } "i" get set-interactor-vars

[ t ] [ "i" get interactor? ] unit-test

[ ] [ "SYMBOL:" "i" get set-editor-string ] unit-test

[ ] [
    "i" get [ "SYMBOL:" parse ] catch go-to-error
] unit-test

[ t ] [
    "i" get control-model doc-end
    "i" get editor-caret* =
] unit-test
