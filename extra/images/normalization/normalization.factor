! Copyright (C) 2009 Doug Coleman, Keith Lazuka
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

! BGR>
: BGR>RGB ( bitmap -- bitmap' )
    3 <sliced-groups> [ <reversed> ] map concat ; inline

: BGR>BGRA ( bitmap -- bitmap' ) add-dummy-alpha ; inline

: BGR>RGBA ( bitmap -- bitmap' ) BGR>RGB add-dummy-alpha ; inline

: BGR>ARGB ( bitmap -- bitmap' )
    3 <sliced-groups> [ 255 suffix <reversed> ] map concat ; inline

! BGRA>
: BGRA>BGR ( bitmap -- bitmap' )
    4 <sliced-groups> [ but-last-slice ] map concat ; inline

: BGRA>RGBA ( bitmap -- bitmap' )
    4 <sliced-groups>
    [ unclip-last-slice [ <reversed> ] dip suffix ] map concat ; inline

: BGRA>RGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ but-last-slice <reversed> ] map concat ; inline

: BGRA>ARGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ <reversed> ] map concat ; inline

! RGB>
: RGB>BGR ( bitmap -- bitmap' ) BGR>RGB ; inline

: RGB>RGBA ( bitmap -- bitmap' ) add-dummy-alpha ; inline

: RGB>BGRA ( bitmap -- bitmap' )
    3 <sliced-groups> [ <reversed> add-dummy-alpha ] map concat ; inline

: RGB>ARGB ( bitmap -- bitmap' )
    3 <sliced-groups> [ 255 prefix ] map concat ; inline

! RGBA>

: RGBA>BGR ( bitmap -- bitmap' ) BGRA>RGB ; inline

: RGBA>BGRA ( bitmap -- bitmap' ) BGRA>RGBA ; inline

: RGBA>RGB ( bitmap -- bitmap' ) BGRA>BGR ; inline

: RGBA>ARGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ unclip-last-slice prefix ] map concat ; inline

! ARGB>

: ARGB>RGB ( bitmap -- bitmap' )
    4 <sliced-groups> [ rest-slice ] map concat ; inline

: ARGB>RGBA ( bitmap -- bitmap' )
    4 <sliced-groups> [ unclip-slice suffix ] map concat ; inline

: ARGB>BGR ( bitmap -- bitmap' )
    4 <sliced-groups> [ rest-slice <reversed> ] map concat ; inline

: ARGB>BGRA ( bitmap -- bitmap' )
    4 <sliced-groups>
    [ unclip-slice [ <reversed> ] dip suffix ] map concat ; inline

! Dispatch
GENERIC# convert-component-order 1 ( image src-order dest-order -- image )

M: RGB convert-component-order
    nip [ >>component-order ] keep {
        { RGB  [ ] }
        { RGBA [ [ RGB>RGBA ] change-bitmap ] }
        { BGRA [ [ BGR>BGRA ] change-bitmap ] }
        { ARGB [ [ RGB>RGBA RGBA>ARGB ] change-bitmap ] }
        { BGR  [ [ RGB>BGR ] change-bitmap ] }
        [ "Cannot convert from RGB to desired component order!" throw ]
    } case ;

M: RGBA convert-component-order
    nip [ >>component-order ] keep {
        { RGBA [ ] }
        { BGRA [ [ RGBA>BGRA ] change-bitmap ] }
        { BGR  [ [ RGBA>BGR ] change-bitmap ] }
        { RGB  [ [ RGBA>RGB ] change-bitmap ] }
        { ARGB [ [ RGBA>ARGB ] change-bitmap ] }
        [ "Cannot convert from RGBA to desired component order!" throw ]
    } case ;

M: BGR convert-component-order
    nip [ >>component-order ] keep {
        { BGR  [ ] }
        { BGRA [ [ BGR>BGRA ] change-bitmap ] }
        { RGB  [ [ BGR>RGB ] change-bitmap ] }
        { RGBA [ [ BGR>RGBA ] change-bitmap ] }
        { ARGB [ [ BGR>ARGB ] change-bitmap ] }
        [ "Cannot convert from BGR to desired component order!" throw ]
    } case ;

M: BGRA convert-component-order
    nip [ >>component-order ] keep {
        { BGRA [ ] }
        { BGR  [ [ BGRA>BGR ] change-bitmap ] }
        { RGB  [ [ BGRA>RGB ] change-bitmap ] }
        { RGBA [ [ BGRA>RGBA ] change-bitmap ] }
        { ARGB [ [ BGRA>ARGB ] change-bitmap ] }
        [ "Cannot convert from BGRA to desired component order!" throw ]
    } case ;

M: ARGB convert-component-order
    nip [ >>component-order ] keep {
        { ARGB [ ] }
        { BGR  [ [ ARGB>BGR ] change-bitmap ] }
        { RGB  [ [ ARGB>RGB ] change-bitmap ] }
        { RGBA [ [ ARGB>RGBA ] change-bitmap ] }
        { BGRA [ [ ARGB>BGRA ] change-bitmap ] }
        [ "Cannot convert from ARGB to desired component order!" throw ]
    } case ;

PRIVATE>

! asserts that component-type must be ubyte-components
: reorder-colors ( image component-order -- image )
    [
        [ component-type>> ubyte-components assert= ]
        [ dup component-order>> ] bi
    ] dip convert-component-order ;

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

