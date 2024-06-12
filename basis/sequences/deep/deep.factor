! Copyright (C) 2007, 2008 Daniel Ehrenberg, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: fry kernel make math sequences strings ;
IN: sequences.deep

! All traversal goes in postorder

GENERIC: branch? ( object -- ? )

M: sequence branch? drop t ;
M: integer branch? drop f ;
M: string branch? drop f ;
M: object branch? drop f ;

: deep-each ( ... obj quot: ( ... elt -- ... ) -- ... )
    [ call ] 2keep over branch?
    [ '[ _ deep-each ] each ] [ 2drop ] if ; inline recursive

: deep-reduce ( ... obj identity quot: ( ... prev elt -- ... next ) -- ... result )
    swapd deep-each ; inline

: deep-map ( ... obj quot: ( ... elt -- ... elt' ) -- ... newobj )
    [ call ] keep over branch?
    [ '[ _ deep-map ] map ] [ drop ] if ; inline recursive

: deep-filter-as ( ... obj quot: ( ... elt -- ... ? ) exemplar -- ... seq )
    [ selector [ deep-each ] dip ] dip [ like ] when* ; inline recursive

: deep-filter ( ... obj quot: ( ... elt -- ... ? ) -- ... seq )
    over [ branch? ] 1verify deep-filter-as ; inline

: deep-reject-as ( ... obj quot: ( ... elt -- ... ? ) exemplar -- ... seq )
    [ [ not ] compose ] dip deep-filter-as ; inline

: deep-reject ( ... obj quot: ( ... elt -- ... ? ) -- ... seq )
    [ not ] compose deep-filter ; inline

: (deep-find) ( ... obj quot: ( ... elt -- ... ? ) -- ... elt ? )
    [ call ] 2check [ drop t ] [
        over branch? [
            [ f ] 2dip '[ nip _ (deep-find) ] any?
        ] [ 2drop f f ] if
    ] if ; inline recursive

: deep-find ( ... obj quot: ( ... elt -- ... ? ) -- ... elt ) (deep-find) drop ; inline

: deep-any? ( ... obj quot: ( ... elt -- ... ? ) -- ... ? ) (deep-find) nip ; inline

: deep-all? ( ... obj quot: ( ... elt -- ... ? ) -- ... ? )
    '[ @ not ] deep-any? not ; inline

: deep-member? ( obj seq -- ? )
    swap '[
        _ swap dup branch? [ member? ] [ 2drop f ] if
    ] deep-find >boolean ;

: deep-subseq-of? ( seq subseq -- ? )
   '[
        _ over branch? [ subseq-of? ] [ 2drop f ] if
    ] deep-find >boolean ;

: deep-map! ( ... obj quot: ( ... elt -- ... elt' ) -- ... obj )
    over branch? [
        '[ _ [ call ] keep over [ deep-map! drop ] dip ] map!
    ] [ drop ] if ; inline recursive

: flatten ( obj -- seq )
    [ branch? ] deep-reject ;

: flatten-as ( obj exemplar -- seq )
    [ branch? ] swap deep-reject-as ;

: flatten1 ( obj -- seq )
    [
        [
            dup branch? [
                [ dup branch? [ % ] [ , ] if ] each
            ] [ , ] if
        ]
    ] keep [ branch? ] 1verify make ;
