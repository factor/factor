! (c)2010 Joe Groff bsd license
USING: combinators.short-circuit fry generalizations kernel
locals macros math quotations sequences ;
FROM: sequences.private => (each) (each-index) (collect) (2each) ;
IN: sequences.unrolled

<PRIVATE
MACRO: (unrolled-each-integer) ( n -- )
    [ iota >quotation ] keep '[ _ dip _ napply ] ;
PRIVATE>

: unrolled-each-integer ( ... n quot: ( ... i -- ... ) -- ... )
    swap (unrolled-each-integer) ; inline

: unrolled-collect ( ... n quot: ( ... n -- ... value ) into -- ... )
    (collect) unrolled-each-integer ; inline

: unrolled-map-integers ( ... n quot: ( ... n -- ... value ) exemplar -- ... newseq )
    [ over ] dip [ [ unrolled-collect ] keep ] new-like ; inline

ERROR: unrolled-bounds-error
    seq unroll-length ;

ERROR: unrolled-2bounds-error
    xseq yseq unroll-length ;

<PRIVATE
: unrolled-bounds-check ( seq len quot -- seq len quot )
    2over swap length > [ 2over unrolled-bounds-error ] when ; inline

:: unrolled-2bounds-check ( xseq yseq len quot -- xseq yseq len quot )
    { [ len xseq length > ] [ len yseq length > ] } 0||
    [ xseq yseq len unrolled-2bounds-error ]
    [ xseq yseq len quot ] if ; inline

: (unrolled-each) ( seq len quot -- len quot )
    swapd (each) nip ; inline

: (unrolled-each-index) ( seq len quot -- len quot )
    swapd (each-index) nip ; inline

: (unrolled-2each) ( xseq yseq len quot -- len quot )
    [ '[ _ ] 2dip ] dip (2each) nip ; inline

: unrolled-each-unsafe ( ... seq len quot: ( ... x -- ... ) -- ... )
    (unrolled-each) unrolled-each-integer ; inline

: unrolled-2each-unsafe ( ... xseq yseq len quot: ( ... x y -- ... ) -- ... )
    (unrolled-2each) unrolled-each-integer ; inline

: unrolled-each-index-unsafe ( ... seq len quot: ( ... x -- ... ) -- ... )
    (unrolled-each-index) unrolled-each-integer ; inline

: unrolled-map-as-unsafe ( ... seq len quot: ( ... x -- ... newx ) exemplar -- ... newseq )
    [ (unrolled-each) ] dip unrolled-map-integers ; inline

: unrolled-2map-as-unsafe ( ... xseq yseq len quot: ( ... x y -- ... newx ) exemplar -- ... newseq )
    [ (unrolled-2each) ] dip unrolled-map-integers ; inline

PRIVATE>

: unrolled-each ( ... seq len quot: ( ... x -- ... ) -- ... )
    unrolled-bounds-check unrolled-each-unsafe ; inline

: unrolled-2each ( ... xseq yseq len quot: ( ... x y -- ... ) -- ... )
    unrolled-2bounds-check unrolled-2each-unsafe ; inline

: unrolled-each-index ( ... seq len quot: ( ... x i -- ... ) -- ... )
    unrolled-bounds-check unrolled-each-index-unsafe ; inline

: unrolled-map-as ( ... seq len quot: ( ... x -- ... newx ) exemplar -- ... newseq )
    [ unrolled-bounds-check ] dip unrolled-map-as-unsafe ; inline

: unrolled-2map-as ( ... xseq yseq len quot: ( ... x y -- ... newx ) exemplar -- ... newseq )
    [ unrolled-2bounds-check ] dip unrolled-2map-as-unsafe ; inline

: unrolled-map ( ... seq len quot: ( ... x -- ... newx ) -- ... newseq )
    pick unrolled-map-as ; inline

: unrolled-2map ( ... xseq yseq len quot: ( ... x y -- ... newx ) -- ... newseq )
    4 npick unrolled-2map-as ; inline

: unrolled-map-index ( ... seq len quot: ( ... x i -- ... newx ) -- ... newseq )
    [ dup length iota ] 2dip unrolled-2map ; inline

