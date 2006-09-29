IN: temporary
USING: gadgets-panes gadgets freetype namespaces kernel
sequences io test prettyprint ;

: maybe-with-freetype
    freetype get [ call ] [ with-freetype ] if ; inline

: #children "pane" get gadget-children length ;

[
    <pane> "pane" set

    #children "num-children" set
    
    "pane" get [ 10000 [ . ] each ] with-stream*
    
    [ t ] [ #children "num-children" get = ] unit-test
] maybe-with-freetype
