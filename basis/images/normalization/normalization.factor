! Copyright (C) 2009 Doug Coleman, Keith Lazuka
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data byte-arrays grouping
images kernel math math.floats.half sequences specialized-arrays ;
FROM: alien.c-types => float ;
IN: images.normalization
SPECIALIZED-ARRAY: half
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: ushort

<PRIVATE

CONSTANT: don't-care 127
CONSTANT: fill-value 255

: permutation ( src dst -- seq )
    swap '[ _ index [ don't-care ] unless* ] { } map-as
    4 don't-care pad-tail ;

: pad4 ( seq -- newseq ) 4 fill-value pad-tail ;

: shuffle ( seq permutation -- newseq )
    swap '[
        dup 4 >= [ drop fill-value ] [ _ nth ] if
    ] B{ } map-as ;

:: permute ( bytes width stride src-order dst-order -- new-bytes )
    src-order name>> :> src
    dst-order name>> :> dst
    bytes stride group
    [
        src length group width head
        [ pad4 src dst permutation shuffle dst length head ] map concat
    ] map concat ;

: stride ( image -- n )
    [ bitmap>> length ] [ dim>> second ] bi / ;

: (reorder-components) ( image src-order dest-order -- image )
    [ [ ] [ dim>> first ] [ stride ] tri ] 2dip
    '[ _ _ _ _ permute ] change-bitmap ;

GENERIC: normalize-component-type* ( image component-type -- image )

: normalize-floats ( float-array -- byte-array )
    [ 255.0 * >integer ] B{ } map-as ;

M: float-components normalize-component-type*
    drop float cast-array normalize-floats ;

M: half-components normalize-component-type*
    drop half cast-array normalize-floats ;

: ushorts>ubytes ( bitmap -- bitmap' )
    ushort cast-array [ -8 shift ] B{ } map-as ; inline

M: ushort-components normalize-component-type*
    drop ushorts>ubytes ;

M: ubyte-components normalize-component-type*
    drop ;

: normalize-scan-line-order ( image -- image' )
    dup upside-down?>> [
        dup dim>> first 4 * '[
            _ <groups> reverse concat
        ] change-bitmap
        f >>upside-down?
    ] when ;

: validate-request ( src-order dst-order -- src-order dst-order )
    [
        [ { DEPTH DEPTH-STENCIL INTENSITY } member? ] bi@
        or [ "Invalid component-order" throw ] when
    ] 2keep ;

PRIVATE>

: reorder-components ( image component-order -- image' )
    [
        dup component-type>> '[ _ normalize-component-type* ] change-bitmap
        dup component-order>>
    ] dip
    validate-request [ (reorder-components) ] keep >>component-order ;

: normalize-image ( image -- image' )
    [ >byte-array ] change-bitmap
    RGBA reorder-components
    normalize-scan-line-order ;
