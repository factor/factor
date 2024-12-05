! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes combinators.short-circuit effects
generic.math io io.styles kernel kernel.private make math.parser
namespaces prettyprint quotations sequences strings summary
tools.continuations words ;
IN: tools.trace

<PRIVATE

: callstack-depth ( callstack -- n )
    callstack>array midpoint ;

SYMBOL: end

: into? ( obj -- ? )
    {
        [ word? ]
        [ predicate? not ]
        [ math-generic? not ]
        [
            [ inline? ]
            [ vocabulary>> { "math" "accessors" } member? not ] bi or
        ]
    } 1&& ;

TUPLE: trace-step-state word inputs ;

M: trace-step-state summary
    [
        [ "Word: " % word>> name>> % ]
        [ " -- inputs: " % inputs>> unparse-short % ] bi
    ] "" make ;

: <trace-step> ( continuation word -- trace-step )
    [ nip ] [ [ data>> ] [ stack-effect in>> length ] bi* index-or-length tail* ] 2bi
    \ trace-step-state boa ;

: print-step ( continuation -- )
    dup continuation-current dup word? [
        [ nip name>> ] [ <trace-step> ] 2bi write-object nl
    ] [
        nip short.
    ] if ;

: print-depth ( continuation -- )
    call>> callstack-depth
    [ CHAR: \s <string> write ]
    [ number>string write ": " write ] bi ;

: trace-into? ( continuation -- ? )
    continuation-current into? ;

: trace-step ( continuation -- continuation' )
    dup call>> innermost-frame-executing quotation? [
        dup continuation-current end eq? [
            [ print-depth ]
            [ print-step ]
            [ dup trace-into? [ continuation-step-into ] [ continuation-step ] if ]
            tri
        ] unless
    ] when ;

PRIVATE>

: trace ( quot -- data )
    [ [ trace-step ] break-hook ] dip
    [ break ] [ end drop ] surround
    with-variable ;

<< \ trace t "no-compile" set-word-prop >>
