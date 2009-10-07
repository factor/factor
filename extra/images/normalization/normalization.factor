! Copyright (C) 2009 Doug Coleman, Keith Lazuka
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types byte-arrays combinators fry
grouping half-floats images kernel math math.vectors sequences
specialized-arrays specialized-arrays.instances.float
specialized-arrays.instances.half
specialized-arrays.instances.uint
specialized-arrays.instances.ushort words ;
FROM: alien.c-types => float ;
IN: images.normalization

<PRIVATE

CONSTANT: don't-care 3

: permutation ( src dst -- seq n )
    [
        swap '[ _ index [ don't-care ] unless* ] { } map-as
        4 don't-care pad-tail
    ] keep length ;

: pad4 ( seq -- newseq ) 4 255 pad-tail ;

: permute ( byte-array src-order dst-order -- byte-array )
   [ name>> [ length ] keep ] [ name>> ] bi*
   permutation [ group ] 2dip '[ pad4 _ vshuffle _ head ] map concat ;

: (reorder-colors) ( image src-order dest-order -- image )
    [ permute ] 2curry change-bitmap ;

GENERIC: normalize-component-type* ( image component-type -- image )

: normalize-floats ( float-array -- byte-array )
    [ 255.0 * >integer ] B{ } map-as ;

M: float-components normalize-component-type*
    drop byte-array>float-array normalize-floats ;

M: half-components normalize-component-type*
    drop byte-array>half-array normalize-floats ;

: ushorts>ubytes ( bitmap -- bitmap' )
    byte-array>ushort-array [ -8 shift ] B{ } map-as ; inline

M: ushort-components normalize-component-type*
    drop ushorts>ubytes ;

M: ubyte-components normalize-component-type*
    drop ;

: normalize-scan-line-order ( image -- image )
    dup upside-down?>> [
        dup dim>> first 4 * '[
            _ <groups> reverse concat
        ] change-bitmap
        f >>upside-down?
    ] when ;

PRIVATE>

: reorder-colors ( image component-order -- image )
    [
        dup component-type>> '[ _ normalize-component-type* ] change-bitmap
        dup component-order>>
    ] dip
    [ (reorder-colors) ] keep >>component-order ;

: normalize-image ( image -- image )
    [ >byte-array ] change-bitmap
    RGBA reorder-colors
    normalize-scan-line-order ;

