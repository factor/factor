USING: kernel math sequences ;

IN: splitting.extras

<PRIVATE

: (split*) ( seq quot: ( ... elt -- ... ? ) slice-quot -- pieces )
    [ 0 ] 3dip pick [
        swap curry [ [ 1 + ] when ] prepose [ 2keep ] curry
        [ 2dup = ] prepose [ [ 1 + ] when swap ] compose [
            [ find-from drop dup ] 2curry [ keep -rot ] curry
        ] dip produce nip
    ] 2keep swap [
        [ length [ swapd dupd < ] keep ] keep
    ] dip 2curry [ suffix ] compose [ drop ] if ; inline

PRIVATE>

: split*-when ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ subseq ] (split*) ; inline

: split*-when-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ <slice> ] (split*) ; inline

: split* ( seq separators -- pieces )
    [ member? ] curry split*-when ; inline

: split*-slice ( seq separators -- pieces )
    [ member? ] curry split*-when-slice ; inline

: split-find ( seq quot: ( seq -- i ) -- pieces )
    [ dup empty? not ] swap [ [ dup ] ] dip
    [ [ [ 1 ] when-zero cut-slice swap ] [ f swap ] if* ] compose
    compose produce nip ; inline
