USING: kernel parser lexer strings math namespaces make
sequences words io arrays quotations debugger accessors
sequences.private ;
IN: state-machine

: STATES:
    ! STATES: set-name state1 state2 ... ;
    ";" parse-tokens
    [ length ] keep
    unclip suffix
    [ create-in swap 1quotation define ] 2each ; parsing

TUPLE: state place data ;

ERROR: missing-state ;

M: missing-state error.
    drop "Missing state" print ;

: make-machine ( states -- table quot )
    ! quot is ( state string -- output-string )
    [ missing-state ] <array> dup
    [
        [ [ dup [ data>> ] [ place>> ] bi ] dip ] %
        [ swapd bounds-check dispatch ] curry ,
        [ each pick (>>place) swap (>>date) ] %
    ] [ ] make [ over make ] curry ;

: define-machine ( word state-class -- )
    execute make-machine
    [ over ] dip define
    "state-table" set-word-prop ;

: MACHINE:
    ! MACHINE: utf8 unicode-states
    CREATE scan-word define-machine ; parsing

: S:
    ! S: state state-machine definition... ;
    ! definition MUST be ( data char -- newdata state )
    scan-word execute scan-word "state-table" word-prop
    parse-definition -rot set-nth ; parsing
