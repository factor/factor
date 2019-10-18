USING: gadgets-walker gadgets-workspace gadgets-listener
namespaces test arrays sequences gadgets kernel listener
threads inspector models freetype ;
IN: temporary

[
    [ ] [ <walker-gadget> "walker" set ] unit-test
    
    ! Make sure the toolbar buttons don't throw errors if we're
    ! not actually walking.
    
    [ ] [ "walker" get com-step ] unit-test
    [ ] [ "walker" get com-into ] unit-test
    [ ] [ "walker" get com-out ] unit-test
    [ ] [ "walker" get com-back ] unit-test
    [ ] [ "walker" get com-inspect ] unit-test
    [ ] [ "walker" get reset-walker ] unit-test
    [ ] [ "walker" get com-continue ] unit-test
    [ ] [ "walker" get com-abandon ] unit-test
    
    [
        f <workspace>
        [
            <gadget> f <model> "" <world> 2array
            V{ } singleton windows set
        ] keep
    
        "ok" off
    
        [
            workspace-listener
            listener-gadget-input
            "ok" on
            parse-interactive
            "c" get continue-with
        ] in-thread drop
    
        [ t ] [ "ok" get ] unit-test
    
        <walker-gadget> "w" set
        continuation "w" get call-tool*
    
        [ "c" set f ] callcc1
        [ "q" set ] [ "w" get com-inspect stop ] if*
        
        [ t ] [
            "q" get dup first continuation?
            swap second \ inspect eq? and
        ] unit-test
    ] with-scope
] with-freetype
