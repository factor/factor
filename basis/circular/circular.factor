! Copyright (C) 2005, 2006 Alex Chapman, Daniel Ehrenberg
! See http;//factorcode.org/license.txt for BSD license
USING: kernel sequences math sequences.private strings
accessors locals fry ;
IN: circular

TUPLE: circular { seq read-only } { start integer } ;

: <circular> ( seq -- circular )
    0 circular boa ; inline

<PRIVATE

: circular-wrap ( n circular -- n circular )
    [ start>> + ] keep
    [ seq>> length rem ] keep ; inline

PRIVATE>

M: circular length seq>> length ; inline

M: circular virtual@ circular-wrap seq>> ; inline

M: circular virtual-exemplar seq>> ; inline

: change-circular-start ( n circular -- )
    #! change start to (start + n) mod length
    circular-wrap (>>start) ; inline

: rotate-circular ( circular -- )
    [ 1 ] dip change-circular-start ; inline

: circular-push ( elt circular -- )
    [ set-first ] [ rotate-circular ] bi ;

: <circular-string> ( n -- circular )
    0 <string> <circular> ; inline

INSTANCE: circular virtual-sequence

TUPLE: growing-circular < circular length ;

M: growing-circular length length>> ; inline

<PRIVATE

: full? ( circular -- ? )
    [ length ] [ seq>> length ] bi = ; inline

PRIVATE>

: growing-circular-push ( elt circular -- )
    dup full? [ circular-push ]
    [ [ 1 + ] change-length set-last ] if ;

: <growing-circular> ( capacity -- growing-circular )
    { } new-sequence 0 0 growing-circular boa ; inline

TUPLE: circular-iterator
    { circular read-only } { n integer } { last-start integer } ;

: <circular-iterator> ( sequence -- obj )
    <circular> 0 0 circular-iterator boa ; inline

<PRIVATE

: (circular-while) ( iterator quot: ( obj -- ? ) -- )
    [ [ [ n>> ] [ circular>> ] bi nth ] dip call ] 2keep rot [
        [
            [ 1 + ] change-n
            dup n>> >>last-start
        ] dip (circular-while)
    ] [
        over [ 1 + ] change-n
        [ n>> ] [ [ last-start>> ] [ circular>> length ] bi + ] bi = [
            2drop
        ] [
            (circular-while)
        ] if
    ] if ; inline recursive

PRIVATE>

: circular-while ( sequence quot: ( obj -- ? ) -- )
    [ <circular-iterator> ] dip (circular-while) ; inline
