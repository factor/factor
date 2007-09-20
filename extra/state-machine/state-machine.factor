USING: kernel parser strings math namespaces sequences words io arrays 
quotations debugger kernel.private ;
IN: state-machine

: STATES:
    ! STATES: set-name state1 state2 ... ;
    ";" parse-tokens
    [ length ] keep
    unclip add
    [ create-in swap 1quotation define-compound ] 2each ; parsing

TUPLE: state place data ;

TUPLE: missing-state ;
: missing-state \ missing-state construct-empty throw ;
M: missing-state error.
    drop "Missing state" print ;

: make-machine ( states -- table quot )
    ! quot is ( state string -- output-string )
    [ missing-state ] <array> dup
    [
        [ >r dup dup state-data swap state-place r> ] %
        [ swapd bounds-check dispatch ] curry ,
        [ each pick set-state-place swap set-state-data ] %
    ] [ ] make [ over make ] curry ;

: define-machine ( word state-class -- )
    execute make-machine
    >r over r> define-compound
    "state-table" set-word-prop ;

: MACHINE:
    ! MACHINE: utf8 unicode-states
    CREATE scan-word define-machine ; parsing

: S:
    ! S: state state-machine definition... ;
    ! definition MUST be ( data char -- newdata state )
    scan-word execute scan-word "state-table" word-prop
    parse-definition -rot set-nth ; parsing
