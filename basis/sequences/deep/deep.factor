! Copyright (C) 2007, 2008 Daniel Ehrenberg, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel strings math fry ;
IN: sequences.deep

! All traversal goes in postorder

GENERIC: branch? ( object -- ? )

M: sequence branch? drop t ;
M: integer branch? drop f ;
M: string branch? drop f ;
M: object branch? drop f ;

: deep-each ( obj quot: ( elt -- ) -- )
    [ call ] 2keep over branch?
    [ '[ _ deep-each ] each ] [ 2drop ] if ; inline recursive

: deep-map ( obj quot: ( elt -- elt' ) -- newobj )
    [ call ] keep over branch?
    [ '[ _ deep-map ] map ] [ drop ] if ; inline recursive

: deep-filter ( obj quot: ( elt -- ? ) -- seq )
    over [ pusher [ deep-each ] dip ] dip
    dup branch? [ like ] [ drop ] if ; inline recursive

: (deep-find) ( obj quot: ( elt -- ? ) -- elt ? )
    [ call ] 2keep rot [ drop t ] [
        over branch? [
            [ f ] 2dip '[ nip _ (deep-find) ] find drop >boolean
        ] [ 2drop f f ] if  
    ] if ; inline recursive

: deep-find ( obj quot -- elt ) (deep-find) drop ; inline

: deep-any? ( obj quot -- ? ) (deep-find) nip ; inline

: deep-all? ( obj quot -- ? )
    '[ @ not ] deep-any? not ; inline

: deep-member? ( obj seq -- ? )
    swap '[
        _ swap dup branch? [ member? ] [ 2drop f ] if
    ] deep-find >boolean ;

: deep-subseq? ( subseq seq -- ? )
    swap '[
        _ swap dup branch? [ subseq? ] [ 2drop f ] if
    ] deep-find >boolean ;

: deep-map! ( obj quot: ( elt -- elt' ) -- obj )
    over branch? [
        '[ _ [ call ] keep over [ deep-map! drop ] dip ] map!
    ] [ drop ] if ; inline recursive

: flatten ( obj -- seq )
    [ branch? not ] deep-filter ;
