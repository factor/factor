IN: temporary
USING: alien gadgets-panes gadgets freetype namespaces kernel
sequences io test prettyprint ;

: #children "pane" get gadget-children length ;

[
    <pane> "pane" set

    #children "num-children" set
    
    "pane" get <pane-stream> [ 10000 [ . ] each ] with-stream*
    
    [ t ] [ #children "num-children" get = ] unit-test
] with-freetype
