! Copyright (C) 2008 Matthew Willis
! See https://factorcode.org/license.txt for BSD license.
!
! these samples are a subset of the samples on
! https://cairographics.org/samples/
USING: cairo cairo.ffi locals math.constants math
io.backend kernel alien.c-types libc namespaces
cairo-gadgets ui.gadgets accessors specialized-arrays
classes.struct ;
SPECIALIZED-ARRAY: double
IN: cairo-samples

TUPLE: arc-gadget < cairo-gadget ;
M:: arc-gadget render-cairo* ( gadget -- )
    128.0 :> xc
    128.0 :> yc
    100.0 :> radius
    pi 1/4 * :> angle1
    pi :> angle2
    cr 10.0 cairo_set_line_width
    cr xc yc radius angle1 angle2 cairo_arc
    cr cairo_stroke

    ! draw helping lines
    cr 1 0.2 0.2 0.6 cairo_set_source_rgba
    cr 6.0 cairo_set_line_width

    cr xc yc 10.0 0 2 pi * cairo_arc
    cr cairo_fill

    cr xc yc radius angle1 angle1 cairo_arc
    cr xc yc cairo_line_to
    cr xc yc radius angle2 angle2 cairo_arc
    cr xc yc cairo_line_to
    cr cairo_stroke
    ;

TUPLE: clip-gadget < cairo-gadget ;
M: clip-gadget render-cairo* ( gadget -- )
    drop
    cr 128 128 76.8 0 2 pi * cairo_arc
    cr cairo_clip
    cr cairo_new_path

    cr 0 0 256 256 cairo_rectangle
    cr cairo_fill
    cr 0 1 0 cairo_set_source_rgb
    cr 0 0 cairo_move_to
    cr 256 256 cairo_line_to
    cr 256 0 cairo_move_to
    cr 0 256 cairo_line_to
    cr 10 cairo_set_line_width
    cr cairo_stroke ;

TUPLE: clip-image-gadget < cairo-gadget ;
M:: clip-image-gadget render-cairo* ( gadget -- )
    "resource:misc/icons/Factor_128x128.png"
    normalize-path cairo_image_surface_create_from_png :> png
    png cairo_image_surface_get_width :> w
    png cairo_image_surface_get_height :> h
    cr 128 128 76.8 0 2 pi * cairo_arc
    cr cairo_clip
    cr cairo_new_path

    cr 192.0 w / 192.0 h / cairo_scale
    cr png 32 32 cairo_set_source_surface
    cr cairo_paint
    png cairo_surface_destroy ;

TUPLE: dash-gadget < cairo-gadget ;
M:: dash-gadget render-cairo* ( gadget -- )
    double-array{ 50 10 10 10 } underlying>> :> dashes
    4 :> ndash
    cr dashes ndash -50 cairo_set_dash
    cr 10 cairo_set_line_width
    cr 128.0 25.6 cairo_move_to
    cr 230.4 230.4 cairo_line_to
    cr -102.4 0 cairo_rel_line_to
    cr 51.2 230.4 51.2 128.0 128.0 128.0 cairo_curve_to
    cr cairo_stroke ;

TUPLE: gradient-gadget < cairo-gadget ;
M:: gradient-gadget render-cairo* ( gadget -- )
    0 0 0 256 cairo_pattern_create_linear :> pat
    115.2 102.4 25.6 102.4 102.4 128.0
    cairo_pattern_create_radial :> radial
    pat 1 0 0 0 1 cairo_pattern_add_color_stop_rgba
    pat 0 1 1 1 1 cairo_pattern_add_color_stop_rgba
    cr 0 0 256 256 cairo_rectangle
    cr pat cairo_set_source
    cr cairo_fill
    pat cairo_pattern_destroy

    radial 0 1 1 1 1 cairo_pattern_add_color_stop_rgba
    radial 1 0 0 0 1 cairo_pattern_add_color_stop_rgba
    cr radial cairo_set_source
    cr 128.0 128.0 76.8 0 2 pi * cairo_arc
    cr cairo_fill
    radial cairo_pattern_destroy ;

TUPLE: text-gadget < cairo-gadget ;
M: text-gadget render-cairo* ( gadget -- )
    drop
    cr "Serif" CAIRO_FONT_SLANT_NORMAL CAIRO_FONT_WEIGHT_BOLD
    cairo_select_font_face
    cr 50 cairo_set_font_size
    cr 10 135 cairo_move_to
    cr "Hello" cairo_show_text

    cr 70 165 cairo_move_to
    cr "factor" cairo_text_path
    cr 0.5 0.5 1 cairo_set_source_rgb
    cr cairo_fill_preserve
    cr 0 0 0 cairo_set_source_rgb
    cr 2.56 cairo_set_line_width
    cr cairo_stroke

    ! draw helping lines
    cr 1 0.2 0.2 0.6 cairo_set_source_rgba
    cr 10 135 5.12 0 2 pi * cairo_arc
    cr cairo_close_path
    cr 70 165 5.12 0 2 pi * cairo_arc
    cr cairo_fill ;

TUPLE: utf8-gadget < cairo-gadget ;
M: utf8-gadget render-cairo* ( gadget -- )
    drop
    cr "Sans" CAIRO_FONT_SLANT_NORMAL CAIRO_FONT_WEIGHT_NORMAL
    cairo_select_font_face
    cr 50 cairo_set_font_size
    cairo_text_extents_t malloc-struct
    cr "日本語" pick cairo_text_extents
    cr over
    [ width>> 2 / ] [ x_bearing>> ] bi +
    128 swap - pick
    [ height>> 2 / ] [ y_bearing>> ] bi +
    128 swap - cairo_move_to
    free
    cr "日本語" cairo_show_text

    cr 1 0.2 0.2 0.6 cairo_set_source_rgba
    cr 6 cairo_set_line_width
    cr 128 0 cairo_move_to
    cr 0 256 cairo_rel_line_to
    cr 0 128 cairo_move_to
    cr 256 0 cairo_rel_line_to
    cr cairo_stroke ;

USING: quotations ui.gadgets.panes sequences ;
: samples ( -- )
    {
        arc-gadget clip-gadget clip-image-gadget dash-gadget
        gradient-gadget text-gadget utf8-gadget
    }
    [ new { 256 256 } >>dim gadget. ] each ;

MAIN: samples
