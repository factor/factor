IN: temporary
USING: gadgets-listener words arrays namespaces test kernel
freetype timers gadgets-workspace ;

timers [ init-timers ] unless

[
    <listener-gadget> "listener" set
    
    [ "dup" ] [ \ dup "listener" get word-completion-string ] unit-test
    
    [ "USE: words word-name" ]
    [ \ word-name "listener" get word-completion-string ] unit-test
] with-freetype
