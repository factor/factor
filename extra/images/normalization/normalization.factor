! Copyright (C) 2009 Doug Coleman, Keith Lazuka
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel accessors grouping sequences
combinators math byte-arrays fry images half-floats
specialized-arrays words ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: ushort
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: half
IN: images.normalization

<PRIVATE

! Helpers
: add-dummy-alpha ( seq -- seq' )
    3 <groups> [ 255 suffix ] map concat ;

: normalize-floats ( float-array -- byte-array )
    [ 255.0 * >integer ] B{ } map-as ;

: fix-XBGR ( bitmap -- bitmap' )
    dup 4 <sliced-groups> [ [ 255 0 ] dip set-nth ] each ;

: fix-BGRX ( bitmap -- bitmap' )
    dup 4 <sliced-groups> [ [ 255 3 ] dip set-nth ] each ;

! Bitmap Conversions

! TODO RGBX, XRGB, BGRX, XBGR conversions

: BGR>BGR ( bitmap -- bitmap' ) ;

: BGR>RGB ( bitmap -- bitmap' )
    3 <sliced-groups> [ <reversed> ] map concat ; inline

: BGR>BGRA ( bitmap -- bitmap' ) add-dummy-alpha ; inline

: BGR>RGBA ( bitmap -- bitmap' ) BGR>RGB add-dummy-alpha ; inline

: BGR>ARGB ( bitmap -- bitmap' )
    3 <sliced-groups> [ 255 suffix <reversed> ] map concat ; inline

: BGRA>BGRA ( bitmap -- bitmap' ) ;

: BGRA>BGR ( bitmap -- bitmap' )
    4 <sliced-groups> [ but-last-slice ] map concat ; inline

: BGRA>RGBA ( bitmap -- bitmap' )
    4 <sliced-groups>
    [ unclip-last-slice [ <reversed> ] dip suffix ] map concat ; inline

: BGRA>RGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ but-last-slice <reversed> ] map concat ; inline

: BGRA>ARGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ <reversed> ] map concat ; inline

: RGB>RGB ( bitmap -- bitmap' ) ;

: RGB>BGR ( bitmap -- bitmap' ) BGR>RGB ; inline

: RGB>RGBA ( bitmap -- bitmap' ) add-dummy-alpha ; inline

: RGB>BGRA ( bitmap -- bitmap' )
    3 <sliced-groups> [ <reversed> add-dummy-alpha ] map concat ; inline

: RGB>ARGB ( bitmap -- bitmap' )
    3 <sliced-groups> [ 255 prefix ] map concat ; inline

: RGBA>RGBA ( bitmap -- bitmap' ) ;

: RGBA>BGR ( bitmap -- bitmap' ) BGRA>RGB ; inline

: RGBA>BGRA ( bitmap -- bitmap' ) BGRA>RGBA ; inline

: RGBA>RGB ( bitmap -- bitmap' ) BGRA>BGR ; inline

: RGBA>ARGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ unclip-last-slice prefix ] map concat ; inline

: ARGB>ARGB ( bitmap -- bitmap' ) ;

: ARGB>RGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ rest-slice ] map concat ; inline

: ARGB>RGBA ( bitmap -- bitmap' )
    4 <sliced-groups> [ unclip-slice suffix ] map concat ; inline

: ARGB>BGR ( bitmap -- bitmap' )
    4 <sliced-groups> [ rest-slice <reversed> ] map concat ; inline

: ARGB>BGRA ( bitmap -- bitmap' )
    4 <sliced-groups>
    [ unclip-slice [ <reversed> ] dip suffix ] map concat ; inline

: (reorder-colors) ( image src-order des-order -- image )
    [ name>> ] bi@ ">" glue "images.normalization.private" lookup
    [ '[ _ execute( image -- image' ) ] change-bitmap ]
    [ "No component-order conversion found." throw ]
    if* ;

PRIVATE>

: reorder-colors ( image component-order -- image )
    [
        [ component-type>> ubyte-components assert= ]
        [ dup component-order>> ] bi
    ] dip (reorder-colors) ;

<PRIVATE

GENERIC: normalize-component-type* ( image component-type -- image )

: normalize-component-order ( image -- image )
    dup component-type>> '[ _ normalize-component-type* ] change-bitmap
    RGBA reorder-colors ;

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

: normalize-image ( image -- image )
    [ >byte-array ] change-bitmap
    normalize-component-order
    normalize-scan-line-order
    RGBA >>component-order ;

