! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel strings math ;
IN: sequences.deep

! All traversal goes in postorder

GENERIC: branch? ( object -- ? )

M: sequence branch? drop t ;
M: integer branch? drop f ;
M: string branch? drop f ;
M: object branch? drop f ;

: deep-each ( obj quot: ( elt -- ) -- )
    [ call ] 2keep over branch?
    [ [ deep-each ] curry each ] [ 2drop ] if ; inline recursive

: deep-map ( obj quot: ( elt -- elt' ) -- newobj )
    [ call ] keep over branch?
    [ [ deep-map ] curry map ] [ drop ] if ; inline recursive

: deep-filter ( obj quot: ( elt -- ? ) -- seq )
    over >r
    pusher >r deep-each r>
    r> dup branch? [ like ] [ drop ] if ; inline recursive

: deep-find-from ( obj quot: ( elt -- ? ) -- elt ? )
    [ call ] 2keep rot [ drop t ] [
        over branch? [
            f -rot [ >r nip r> deep-find-from ] curry find drop >boolean
        ] [ 2drop f f ] if  
    ] if ; inline recursive

: deep-find ( obj quot -- elt ) deep-find-from drop ; inline

: deep-contains? ( obj quot -- ? ) deep-find-from nip ; inline

: deep-all? ( obj quot -- ? )
    [ not ] compose deep-contains? not ; inline

: deep-change-each ( obj quot: ( elt -- elt' ) -- )
    over branch? [ [
        [ call ] keep over >r deep-change-each r>
    ] curry change-each ] [ 2drop ] if ; inline recursive

: flatten ( obj -- seq )
    [ branch? not ] deep-filter ;
