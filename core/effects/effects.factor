! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser math.order namespaces make
sequences strings words assocs combinators accessors arrays
quotations ;
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
    swap [ rot ] dip [ ?terminated ] 2dip effect boa ;

: effect-height ( effect -- n )
    [ out>> length ] [ in>> length ] bi - ; inline

: variable-effect? ( effect -- ? )
    [ in-var>> ] [ out-var>> ] bi or ;
: bivariable-effect? ( effect -- ? )
    [ in-var>> ] [ out-var>> ] bi = not ;

: effect<= ( effect1 effect2 -- ? )
    {
        { [ over terminated?>> ] [ t ] }
        { [ dup terminated?>> ] [ f ] }
        { [ 2dup [ bivariable-effect? ] either? ] [ f ] }
        { [ 2dup [ variable-effect? ] [ variable-effect? not ] bi* and ] [ f ] }
        { [ 2dup [ in>> length ] bi@ > ] [ f ] }
        { [ 2dup [ effect-height ] bi@ = not ] [ f ] }
        [ t ]
    } cond 2nip ; inline

: effect= ( effect1 effect2 -- ? )
    [ [ in>> length ] bi@ = ]
    [ [ out>> length ] bi@ = ]
    [ [ terminated?>> ] bi@ = ]
    2tri and and ;

GENERIC: effect>string ( obj -- str )
M: string effect>string ;
M: object effect>string drop "object" ;
M: word effect>string name>> ;
M: integer effect>string number>string ;
M: pair effect>string first2 [ effect>string ] bi@ ": " glue ;

: stack-picture ( seq -- string )
    [ [ effect>string % CHAR: \s , ] each ] "" make ;

: var-picture ( var -- string )
    [ ".." " " surround ]
    [ "" ] if* ;

M: effect effect>string ( effect -- string )
    [
        "( " %
        dup in-var>> var-picture %
        dup in>> stack-picture % "-- " %
        dup out-var>> var-picture %
        dup out>> stack-picture %
        dup terminated?>> [ "* " % ] when
        drop
        ")" %
    ] "" make ;

GENERIC: effect>type ( obj -- type )
M: object effect>type drop object ;
M: word effect>type ;
M: pair effect>type second effect>type ;

: effect-in-types ( effect -- input-types )
    in>> [ effect>type ] map ;

: effect-out-types ( effect -- input-types )
    out>> [ effect>type ] map ;

GENERIC: stack-effect ( word -- effect/f )

M: word stack-effect
    [ "declared-effect" word-prop ]
    [ parent-word dup [ stack-effect ] when ] bi or ;

M: deferred stack-effect call-next-method (( -- * )) or ;

M: effect clone
    [ in>> clone ] [ out>> clone ] bi <effect> ;

: stack-height ( word -- n )
    stack-effect effect-height ;

: split-shuffle ( stack shuffle -- stack1 stack2 )
    in>> length cut* ;

: shuffle-mapping ( effect -- mapping )
    [ out>> ] [ in>> ] bi [ index ] curry map ;

: shuffle ( stack shuffle -- newstack )
    shuffle-mapping swap nths ;

: add-effect-input ( effect -- effect' )
    [ in>> "obj" suffix ] [ out>> ] [ terminated?>> ] tri <terminated-effect> ;

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
