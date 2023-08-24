! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes combinators kernel make math
math.order math.parser sequences sequences.private strings words ;
IN: effects

TUPLE: effect
{ in array read-only }
{ out array read-only }
{ terminated? read-only }
{ in-var read-only }
{ out-var read-only } ;

: ?terminated ( out -- out terminated? )
    dup { "*" } = [ drop { } t ] [ f ] if ;

: <effect> ( in out -- effect )
    ?terminated f f effect boa ;

: <terminated-effect> ( in out terminated? -- effect )
    f f effect boa ; inline

: <variable-effect> ( in-var in out-var out -- effect )
    swap rotd [ ?terminated ] 2dip effect boa ;

: effect-height ( effect -- n )
    [ out>> length ] [ in>> length ] bi - ; inline

: variable-effect? ( effect -- ? )
    dup in-var>> [ drop t ] [ out-var>> ] if ;

: bivariable-effect? ( effect -- ? )
    [ in-var>> ] [ out-var>> ] bi = not ;

: effect<= ( effect1 effect2 -- ? )
    {
        { [ over terminated?>> ] [ t ] }
        { [ dup terminated?>> ] [ f ] }
        { [ 2dup [ bivariable-effect? ] either? ] [ f ] }
        { [ 2dup [ variable-effect? ] [ variable-effect? not ] bi* and ] [ f ] }
        { [ 2dup [ in>> length ] bi@ > ] [ f ] }
        { [ 2dup [ effect-height ] same? not ] [ f ] }
        [ t ]
    } cond 2nip ; inline

: effect= ( effect1 effect2 -- ? )
    2dup [ in>> length ] same? [
        2dup [ out>> length ] same? [
            [ terminated?>> ] same?
        ] [ 2drop f ] if
    ] [ 2drop f ] if ;

GENERIC: effect>string ( obj -- str )
M: string effect>string ;
M: object effect>string drop "object" ;
M: word effect>string name>> ;
M: integer effect>string number>string ;
M: pair effect>string
    first2-unsafe over [
        [ effect>string ] bi@ ": " glue
    ] [
        nip effect>string ":" prepend
    ] if ;

<PRIVATE

: stack-picture% ( seq -- )
    [ effect>string % CHAR: \s , ] each ;

: var-picture% ( var -- )
    [ ".." % % CHAR: \s , ] when* ;

PRIVATE>

M: effect effect>string
    [
        "( " %
        dup in-var>> var-picture%
        dup in>> stack-picture% "-- " %
        dup out-var>> var-picture%
        dup out>> stack-picture%
        dup terminated?>> [ "* " % ] when
        drop
        ")" %
    ] "" make ;

GENERIC: effect>type ( obj -- type )
M: object effect>type drop object ;
M: word effect>type ;
M: pair effect>type second-unsafe effect>type ;
M: classoid effect>type ;

: effect-in-types ( effect -- input-types )
    in>> [ effect>type ] map ;

: effect-out-types ( effect -- input-types )
    out>> [ effect>type ] map ;

GENERIC: stack-effect ( word -- effect/f )

M: word stack-effect
    dup "declared-effect" word-prop [ nip ] [
        parent-word dup [ stack-effect ] when
    ] if* ;

M: deferred stack-effect call-next-method ( -- * ) or ;

M: effect clone
    {
        [ in>> clone ]
        [ out>> clone ]
        [ terminated?>> ]
        [ in-var>> ]
        [ out-var>> ]
    } cleave effect boa ;

: stack-height ( word -- n )
    stack-effect effect-height ; inline

: shuffle-mapping ( effect -- mapping )
    [ out>> ] [ in>> ] bi [ index ] curry map ;

: shuffle ( stack shuffle -- newstack )
    shuffle-mapping swap nths ;

: add-effect-input ( effect -- effect' )
    [ in>> "obj" suffix ] [ out>> ] [ terminated?>> ] tri
    <terminated-effect> ;

: compose-effects ( effect1 effect2 -- effect' )
    over terminated?>> [
        drop
    ] [
        [ [ [ in>> length ] [ out>> length ] bi ] [ in>> length ] bi* swap [-] + ]
        [ [ out>> length ] [ [ in>> length ] [ out>> length ] bi ] bi* [ [-] ] dip + ]
        [ nip terminated?>> ] 2tri
        [ [ "x" <array> ] bi@ ] dip
        <terminated-effect>
    ] if ; inline

: curry-effect ( effect -- effect' )
    [ in>> length ] [ out>> length ] [ terminated?>> ] tri
    pick 0 = [ [ 1 + ] dip ] [ [ 1 - ] 2dip ] if
    [ [ "x" <array> ] bi@ ] dip <terminated-effect> ;

ERROR: bad-stack-effect word got expected ;

: check-stack-effect ( word effect -- )
    over stack-effect 2dup effect=
    [ 3drop ] [ bad-stack-effect ] if ;
