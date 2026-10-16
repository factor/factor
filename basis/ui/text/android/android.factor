! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data android.ffi arrays
classes.struct colors continuations destructors fonts grouping images
io.encodings.string io.encodings.utf8 kernel libc locals math math.bitwise
math.functions math.order namespaces opengl sequences ui.text ui.text.private ;
IN: ui.text.android

SINGLETON: android-text-renderer
M: android-text-renderer draws-selection-background? t ;

:: <android-layout> ( font object -- layout )
    object selection? [ object string>> ] [ object ] if :> string
    string utf8 encode dup length font name>> font size>> gl-scale
    font bold?>> [ 1 ] [ 0 ] if font italic?>> [ 1 ] [ 0 ] if
    factor_android_text_create dup
    [ ] [ "Android could not create a text layout" throw ] if ;

:: with-android-layout ( ..a font object quot: ( ..a layout -- ..b ) -- ..b )
    font object <android-layout>
    [ &factor_android_text_destroy quot call ] with-destructors ; inline

:: channel>byte ( value -- byte ) value 0.0 1.0 clamp 255.0 * round >integer ;

:: color>argb ( color -- argb )
    color >rgba-components :> ( r g b a )
    a channel>byte 24 shift r channel>byte 16 shift bitor
    g channel>byte 8 shift bitor b channel>byte bitor ;

: background>argb ( color/f -- argb ) [ color>argb ] [ 0 ] if* ;
: foreground>argb ( color/f -- argb ) [ color>argb ] [ 0xff000000 ] if* ;

:: layout-metrics ( font string -- metrics )
    font string [| layout |
        factor-android-text-metrics <struct> :> native
        layout native factor_android_text_metrics drop
        metrics new
            native width>> >>width native ascent>> >>ascent
            native descent>> >>descent native height>> >>height
            native leading>> >>leading native cap-height>> >>cap-height
            native x-height>> >>x-height
    ] with-android-layout ;

M: android-text-renderer string-dim
    layout-metrics [ width>> ] [ height>> ] bi 2array scale-dim ;

M: android-text-renderer font-metrics
    " " layout-metrics clone scale-metrics f >>width ;

M: android-text-renderer line-metrics layout-metrics clone scale-metrics ;

M:: android-text-renderer offset>x ( n font string -- x )
    font string [ n factor_android_text_offset_x ] with-android-layout gl-unscale ;

M:: android-text-renderer x>offset ( x font string -- n )
    font string [ x gl-scale factor_android_text_x_offset ] with-android-layout ;

M:: android-text-renderer selection-spans ( start end font string -- spans )
    font string [| layout |
        layout start end f 0 factor_android_text_selection_spans :> count
        count alien.c-types:float heap-size * malloc &free :> data
        layout start end data count factor_android_text_selection_spans drop
        data count alien.c-types:float <c-direct-array> >array
        2 group [ [ gl-unscale ] map ] map
    ] with-android-layout ;

M:: android-text-renderer string>image ( font object -- image loc )
    font object [| layout |
        object selection? [
            object [ start>> ] [ end>> ] [ color>> color>argb ] tri
        ] [ -1 -1 0 ] if :> ( selection-start selection-end selection-color )
        0 int <ref> :> width
        0 int <ref> :> height
        font foreground>> foreground>argb :> foreground
        font background>> background>argb :> background
        layout foreground background selection-start selection-end selection-color
        width height factor_android_text_render :> pixels
        pixels [ ] [ "Android could not rasterize text" throw ] if
        width int deref height int deref 2array :> dim
        pixels dim product 4 * memory>byte-array :> bitmap
        pixels factor_android_free
        <image> dim >>dim RGBA >>component-order
        ubyte-components >>component-type f >>upside-down?
        t >>premultiplied-alpha? bitmap >>bitmap
        { 0 0 }
    ] with-android-layout ;

M: android-text-renderer flush-layout-cache ;
M: android-text-renderer free-fonts drop ;

android-text-renderer font-renderer set-global
