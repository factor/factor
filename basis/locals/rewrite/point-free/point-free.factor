! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel math quotations sequences
words combinators make locals.backend locals.types
locals.errors ;
IN: locals.rewrite.point-free

! Step 3: rewrite locals usage within a single quotation into
! retain stack manipulation

: local-index ( args obj -- n )
    2dup '[ unquote _ eq? ] find drop
    [ 2nip ] [ bad-local ] if* ;

: read-local-quot ( args obj -- quot )
    local-index neg [ get-local ] curry ;

GENERIC: localize ( args obj -- args quot )

M: local localize dupd read-local-quot ;

M: quote localize dupd local>> read-local-quot ;

M: local-reader localize dupd read-local-quot [ local-value ] append ;

M: local-writer localize
    dupd "local-reader" word-prop
    read-local-quot [ set-local-value ] append ;

M: def localize
    local>>
    [ prefix ]
    [ local-reader? [ 1array load-local ] [ load-local ] ? ]
    bi ;

M: object localize 1quotation ;

! We special-case all the :> at the start of a quotation
: load-locals-quot ( args -- quot )
    [ [ ] ] [
        dup [ local-reader? ] any? [
            dup [ local-reader? [ 1array ] [ ] ? ] map
            deep-spread>quot
        ] [ [ ] ] if swap length [ load-locals ] curry append
    ] if-empty ;

: load-locals-index ( quot -- n )
    [ [ dup def? [ local>> local-reader? ] [ drop t ] if ] find drop ]
    [ length ] bi or ;

: point-free-start ( quot -- args rest )
    dup load-locals-index
    cut [ [ local>> ] map dup <reversed> load-locals-quot % ] dip ;

: point-free-body ( args quot -- args )
    [ localize % ] each ;

: drop-locals-quot ( args -- )
    [ length , [ drop-locals ] % ] unless-empty ;

: point-free-end ( args obj -- )
    dup special?
    [ localize % drop-locals-quot ]
    [ [ drop-locals-quot ] [ , ] bi* ]
    if ;

: point-free ( quot -- newquot )
    [
        point-free-start
        [ drop-locals-quot ] [
            unclip-last
            [ point-free-body ]
            [ point-free-end ]
            bi*
        ] if-empty
    ] [ ] make ;
