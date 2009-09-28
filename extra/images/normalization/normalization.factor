! Copyright (C) 2009 Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel accessors grouping sequences
combinators math byte-arrays fry images half-floats
specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: ushort
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: half
IN: images.normalization

<PRIVATE

: add-dummy-alpha ( seq -- seq' )
    3 <groups> [ 255 suffix ] map concat ;

: normalize-floats ( float-array -- byte-array )
    [ 255.0 * >integer ] B{ } map-as ;

GENERIC: normalize-component-type* ( image component-type -- image )
GENERIC: normalize-component-order* ( image component-order -- image )

: normalize-component-order ( image -- image )
    dup component-type>> '[ _ normalize-component-type* ] change-bitmap
    dup component-order>> '[ _ normalize-component-order* ] change-bitmap ;

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

M: RGBA normalize-component-order* drop ;

: BGR>RGB ( bitmap -- pixels )
    3 <sliced-groups> [ <reversed> ] map B{ } join ; inline

: BGRA>RGBA ( bitmap -- pixels )
    4 <sliced-groups>
    [ unclip-last-slice [ <reversed> ] dip suffix ] map concat ; inline

M: BGRA normalize-component-order*
    drop BGRA>RGBA ;

M: RGB normalize-component-order*
    drop add-dummy-alpha ;

M: BGR normalize-component-order*
    drop BGR>RGB add-dummy-alpha ;

: ARGB>RGBA ( bitmap -- bitmap' )
    4 <groups> [ unclip suffix ] map B{ } join ; inline

M: ARGB normalize-component-order*
    drop ARGB>RGBA ;

M: ABGR normalize-component-order*
    drop ARGB>RGBA BGRA>RGBA ;

: fix-XBGR ( bitmap -- bitmap' )
    dup 4 <sliced-groups> [ [ 255 0 ] dip set-nth ] each ;

M: XBGR normalize-component-order*
    drop fix-XBGR ABGR normalize-component-order* ;

: fix-BGRX ( bitmap -- bitmap' )
    dup 4 <sliced-groups> [ [ 255 3 ] dip set-nth ] each ;

M: BGRX normalize-component-order*
    drop fix-BGRX BGRA normalize-component-order* ;

: normalize-scan-line-order ( image -- image )
    dup upside-down?>> [
        dup dim>> first 4 * '[
            _ <groups> reverse concat
        ] change-bitmap
        f >>upside-down?
    ] when ;

PRIVATE>

: normalize-image ( image -- image )
    [ >byte-array ] change-bitmap
    normalize-component-order
    normalize-scan-line-order
    RGBA >>component-order ;
