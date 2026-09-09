! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators fonts kernel locals math
sequences strings ;
IN: fonts.shaping

SINGLETONS: left-to-right right-to-left ;

TUPLE: shaped-font < font shaping-options ;

ERROR: invalid-text-direction direction ;
ERROR: invalid-tab-width width ;
ERROR: invalid-font-features features ;
ERROR: invalid-font-locale locale ;

<PRIVATE

GENERIC: font-shaping-options ( font -- options )
M: font font-shaping-options drop H{ } ;
M: shaped-font font-shaping-options shaping-options>> ;

GENERIC: >shaped-font ( font -- font' )
M: font >shaped-font
    shaped-font new H{ } clone >>shaping-options swap {
        [ name>> >>name ] [ size>> >>size ]
        [ bold?>> >>bold? ] [ italic?>> >>italic? ]
        [ foreground>> >>foreground ] [ background>> >>background ]
    } cleave ;
M: shaped-font >shaped-font clone [ clone ] change-shaping-options ;

:: font-with-option ( font key value -- font' )
    font >shaped-font :> result
    value key result shaping-options>> set-at
    result ;

: valid-feature-tag? ( tag -- ? )
    dup string? [
        [ length 4 = ] [ [ [ 32 >= ] [ 126 <= ] bi and ] all? ] bi and
    ] [ drop f ] if ;

: valid-feature-value? ( value -- ? )
    dup integer? [ [ 0 >= ] [ 0xffffffff <= ] bi and ] [ drop f ] if ;

PRIVATE>

: font-text-direction ( font -- direction/f )
    font-shaping-options "direction" of ;
: font-tab-width ( font -- width/f )
    font-shaping-options "tab-width" of ;
: font-features ( font -- features )
    font-shaping-options "features" of H{ } or ;
: font-locale ( font -- locale )
    font-shaping-options "locale" of "en-us" or ;
: font-color-fonts? ( font -- ? )
    font-shaping-options "color-fonts?" swap at* [ drop t ] unless ;

: font-with-direction ( font direction/f -- font' )
    dup { f left-to-right right-to-left } member? [ invalid-text-direction ] unless
    "direction" swap font-with-option ;

: font-with-tab-width ( font width/f -- font' )
    dup [ dup real? [ dup [ 0 > ] [ 1/0. < ] bi and ] [ f ] if
        [ invalid-tab-width ] unless ] when
    "tab-width" swap font-with-option ;

: font-with-features ( font assoc -- font' )
    dup [ [ valid-feature-tag? ] [ valid-feature-value? ] bi* and ] assoc-all?
    [ invalid-font-features ] unless
    clone "features" swap font-with-option ;

: font-with-locale ( font locale -- font' )
    dup string? [ dup empty? not ] [ f ] if
    [ invalid-font-locale ] unless
    "locale" swap font-with-option ;

: font-with-color-fonts ( font ? -- font' )
    >boolean "color-fonts?" swap font-with-option ;

M: shaped-font derive-font
    [ [ >shaped-font ] dip call-next-method ] keep
    font-shaping-options over shaping-options>> swap assoc-union
    >>shaping-options ;
