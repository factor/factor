IN: temporary
USING: alien gadgets-panes gadgets freetype namespaces kernel
sequences io test prettyprint definitions help ;

: #children "pane" get gadget-children length ;

[
    [ ] [ <pane> "pane" set ] unit-test

    [ ] [ #children "num-children" set ] unit-test
    
    [ ] [
        "pane" get <pane-stream> [ 10000 [ . ] each ] with-stream*
    ] unit-test
    
    [ t ] [ #children "num-children" get = ] unit-test

    : test-gadget-text
        dup H{ } make-pane gadget-text
        swap string-out "\n" ?tail drop "\n" ?tail drop = ;

    [ t ] [ [ "hello" write ] test-gadget-text ] unit-test
    [ t ] [ [ "hello" pprint ] test-gadget-text ] unit-test
    [ t ] [ [ [ 1 2 3 ] pprint ] test-gadget-text ] unit-test
    [ t ] [ [ \ = see ] test-gadget-text ] unit-test
    [ t ] [ [ \ = help ] test-gadget-text ] unit-test
    [ t ] [ [ "sequences" help ] test-gadget-text ] unit-test
    
] with-freetype
