! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel strings math ;
IN: sequences.deep

! All traversal goes in postorder

: branch? ( object -- ? )
    dup sequence? [
        dup string? swap number? or not
    ] [ drop f ] if ;

: deep-each ( obj quot -- )
    [ call ] 2keep over branch?
    [ [ deep-each ] curry each ] [ 2drop ] if ; inline

: deep-map ( obj quot -- newobj )
    [ call ] keep over branch?
    [ [ deep-map ] curry map ] [ drop ] if ; inline

: deep-subset ( obj quot -- seq )
    over >r
    pusher >r deep-each r>
    r> dup branch? [ like ] [ drop ] if ; inline

: deep-find* ( obj quot -- elt ? )
    [ call ] 2keep rot [ drop t ] [
        over branch? [
            f -rot [ >r nip r> deep-find* ] curry find drop >boolean
        ] [ 2drop f f ] if  
    ] if ; inline

: deep-find ( obj quot -- elt ) deep-find* drop ; inline

: deep-contains? ( obj quot -- ? ) deep-find* nip ; inline

: deep-all? ( obj quot -- ? )
    [ not ] compose deep-contains? not ; inline

: deep-change-each ( obj quot -- )
    over branch? [ [
        [ call ] keep over >r deep-change-each r>
    ] curry change-each ] [ 2drop ] if ; inline

: flatten ( obj -- seq )
    [ branch? not ] deep-subset ;
