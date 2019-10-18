USING: hints kernel math sequences strings ;

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

<PRIVATE

: (split-harvest) ( seq quot: ( ... elt -- ... ? ) slice-quot -- pieces )
    [ [ [ not ] compose find drop 0 or ] 2keep ] dip [
        drop
        dupd [ find-from drop ] 2curry [ 1 + ] prepose
        [ keep swap ] curry
        swap [ length 2dup >= [ drop f ] when ] curry
        [ unless* ] curry compose
        [ [ dup ] if dup ] curry [ dup ] prepose
    ] [
        pick swap curry [ keep swap ] curry -rot
        [ not ] compose [ find-from drop ] 2curry
        [ 1 + ] prepose [ dip ] curry compose
    ] 3bi produce 2nip ; inline

PRIVATE>

: split-when-harvest ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ subseq ] (split-harvest) ; inline

: split-when-slice-harvest ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ <slice> ] (split-harvest) ; inline

: split-harvest ( seq separators -- pieces )
    [ member? ] curry split-when-harvest ; inline

{ split* split*-slice split-harvest }
[ { string string } set-specializer ] each
