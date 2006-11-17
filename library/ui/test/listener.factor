IN: temporary
USING: gadgets-listener words arrays namespaces test kernel
freetype ;

[
    <listener-gadget> "listener" set
    
    "kernel" vocab 1array "listener" get set-listener-gadget-use
    
    [ "dup" ] [ \ dup "listener" get completion-string ] unit-test
    
    [ "USE: words word-name" ]
    [ \ word-name "listener" get completion-string ] unit-test
    
    [ ] [ "listener" get show-history ] unit-test
] with-freetype
