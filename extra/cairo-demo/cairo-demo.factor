! Cairo "Hello World" demo
!  Copyright (c) 2007 Sampo Vuori
!    License: https://factorcode.org/license.txt
!
! This example is an adaptation of the following cairo sample code:
!  https://cairographics.org/samples/text/


USING: accessors byte-arrays cairo.ffi combinators kernel math
math.constants opengl.gl pango.cairo.ffi ui ui.gadgets ui.render ;

IN: cairo-demo

: make-image-array ( -- array )
    384 256 4 * * <byte-array> ;

: convert-array-to-surface ( array -- cairo_surface_t )
    CAIRO_FORMAT_ARGB32 384 256 over 4 *
    cairo_image_surface_create_for_data ;

TUPLE: cairo-demo-gadget < gadget image-array cairo-t ;

M: cairo-demo-gadget draw-gadget* ( gadget -- )
    0 0 glRasterPos2i
    1.0 -1.0 glPixelZoom
    [ 384 256 GL_RGBA GL_UNSIGNED_BYTE ] dip
    image-array>> glDrawPixels ;

: create-surface ( gadget -- cairo_surface_t )
    make-image-array [ swap image-array<< ] keep
    convert-array-to-surface ;

: init-cairo ( gadget -- cairo_t )
    create-surface cairo_create ;

M: cairo-demo-gadget pref-dim* drop { 384 256 } ;

ERROR: no-cairo-t ;

<PRIVATE

: draw-hello-world ( gadget -- )
    cairo-t>> [ no-cairo-t ] unless*
    {
        [
            "Sans" CAIRO_FONT_SLANT_NORMAL CAIRO_FONT_WEIGHT_BOLD
            cairo_select_font_face
        ]
        [ 90.0 cairo_set_font_size ]
        [ 10.0 135.0 cairo_move_to ]
        [ "Hello" cairo_show_text ]
        [ 70.0 165.0 cairo_move_to ]
        [ "World" cairo_text_path ]
        [ 0.5 0.5 1 cairo_set_source_rgb ]
        [ cairo_fill_preserve ]
        [ 0 0 0 cairo_set_source_rgb ]
        [ 2.56 cairo_set_line_width ]
        [ cairo_stroke ]
        [ 1 0.2 0.2 0.6 cairo_set_source_rgba ]
        [ 10.0 135.0 5.12 0 pi 2 * cairo_arc ]
        [ cairo_close_path ]
        [ 70.0 165.0 5.12 0 pi 2 * cairo_arc ]
        [ cairo_fill ]
    } cleave ;

PRIVATE>

M: cairo-demo-gadget graft* ( gadget -- )
    dup dup init-cairo swap cairo-t<< draw-hello-world ;

M: cairo-demo-gadget ungraft* ( gadget -- )
    cairo-t>> cairo_destroy ;

: <cairo-demo-gadget> ( -- gadget )
    cairo-demo-gadget new ;

MAIN-WINDOW: run-cairo-demo
    { { title "Hello World from Factor!" } }
    <cairo-demo-gadget> >>gadgets ;
