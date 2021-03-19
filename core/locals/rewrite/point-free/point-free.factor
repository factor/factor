! Copyright (C) 2007, 2008 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators fry.private kernel
locals.backend locals.errors locals.types make math quotations
sequences words ;
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

M: multi-def localize
    locals>> <reversed>
    [ prepend ]
    [ [ [ local-reader? ] dip '[ [ 1array ] _ [ndip] ] [ [ ] ] if ] map-index concat ]
    [ length [ load-locals ] curry ] tri append ;

M: object localize 1quotation ;

: drop-locals-quot ( args -- )
    [ length , [ drop-locals ] % ] unless-empty ;

: point-free ( quot -- newquot )
    [ { } swap [ localize % ] each drop-locals-quot ] [ ] make ;
