USING: hints kernel math sequences sequences.private strings ;
IN: splitting.extras

<PRIVATE

:: (split*) ( ... seq quot: ( ... elt -- ... ? ) slice-quot -- ... pieces )
    0 [
        [ seq quot find-from drop dup ] keep -rot
    ] [
        2dup = [ [ 1 + ] when seq slice-quot call ] 2keep
        [ 1 + ] when swap
    ] produce nip swap seq length [ dupd < ] keep
    '[ _ seq slice-quot call suffix ] [ drop ] if ; inline

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

: split-head ( seq quot -- before after )
    (trim-head) cut ; inline

: split-tail ( seq quot -- before after )
    (trim-tail) cut ; inline

: split-head-slice ( seq quot -- before after )
    (trim-head) cut-slice ; inline

: split-tail-slice ( seq quot -- before after )
    (trim-tail) cut-slice ; inline

<PRIVATE

:: (split-harvest) ( ... seq quot: ( ... elt -- ... ? ) slice-quot -- ... pieces )
    seq [ quot call not ] find drop [
        [
            [ seq quot find-from drop ] keep swap
            [ seq length ] unless* dup
        ] [ f f f ] if*
    ] [
        [ seq slice-quot call ] keep swap
        [ 1 + seq [ quot call not ] find-from drop ] dip
    ] produce 2nip ; inline

PRIVATE>

: split-when-harvest ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ subseq ] (split-harvest) ; inline

: split-when-slice-harvest ( ... seq quot: ( ... elt -- ... ? ) -- ... pieces )
    [ <slice> ] (split-harvest) ; inline

: split-harvest ( seq separators -- pieces )
    [ member? ] curry split-when-harvest ; inline

{ split* split*-slice split-harvest }
[ { string string } set-specializer ] each
