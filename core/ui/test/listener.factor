IN: temporary
USING: gadgets-listener words arrays namespaces test kernel
freetype timers gadgets-workspace ;

timers [ init-timers ] unless

[
    <listener-gadget> "listener" set
    
    "kernel" vocab 1array "listener" get set-listener-gadget-use
    
    [ "dup" ] [ \ dup "listener" get word-completion-string ] unit-test
    
    [ "USE: words word-name" ]
    [ \ word-name "listener" get word-completion-string ] unit-test
] with-freetype
