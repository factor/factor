IN: temporary
USING: gadgets-listener words arrays namespaces test kernel
freetype timers gadgets-interactor gadgets-workspace sequences
gadgets-text gadgets parser hashtables errors gadgets-panes ;

timers [ init-timers ] unless

[ f ] [ "word" source-editor command-map empty? ] unit-test

[
    <listener-gadget> "listener" set
    
    { "kernel" } [ vocab ] map use associate
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
] with-freetype
