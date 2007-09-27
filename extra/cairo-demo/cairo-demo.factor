! Cairo "Hello World" demo
!  Copyright (c) 2007 Sampo Vuori
!    License: http://factorcode.org/license.txt
!
! This example is an adaptation of the following cairo sample code:
!  http://cairographics.org/samples/text/


USING: cairo math math.constants byte-arrays kernel ui ui.render
	   ui.gadgets opengl.gl ;

IN: cairo-demo


: make-image-array ( -- array )
  384 256 4 * * <byte-array> ;

: convert-array-to-surface ( array -- cairo_surface_t )
  CAIRO_FORMAT_ARGB32 384 256 over 4 *
  cairo_image_surface_create_for_data ;


TUPLE: cairo-gadget image-array cairo-t ;

M: cairo-gadget draw-gadget* ( gadget -- )
   0 0 glRasterPos2i
   1.0 -1.0 glPixelZoom
   >r 384 256 GL_RGBA GL_UNSIGNED_BYTE r>
   cairo-gadget-image-array glDrawPixels ;

: create-surface ( gadget -- cairo_surface_t )
  make-image-array dup >r swap set-cairo-gadget-image-array r> convert-array-to-surface ;

: init-cairo ( gadget -- cairo_t )
   create-surface cairo_create ;

M: cairo-gadget pref-dim* drop { 384 256 0 } ;

: draw-hello-world ( gadget -- )
  cairo-gadget-cairo-t
  dup "Sans" CAIRO_FONT_SLANT_NORMAL CAIRO_FONT_WEIGHT_BOLD cairo_select_font_face
  dup 90.0 cairo_set_font_size
  dup 10.0 135.0 cairo_move_to
  dup "Hello" cairo_show_text
  dup 70.0 165.0 cairo_move_to
  dup "World" cairo_text_path
  dup 0.5 0.5 1 cairo_set_source_rgb
  dup cairo_fill_preserve
  dup 0 0 0 cairo_set_source_rgb
  dup 2.56 cairo_set_line_width
  dup cairo_stroke
  dup 1 0.2 0.2 0.6 cairo_set_source_rgba
  dup 10.0 135.0 5.12 0 pi 2 * cairo_arc
  dup cairo_close_path
  dup 70.0 165.0 5.12 0 pi 2 * cairo_arc
  cairo_fill ;

M: cairo-gadget graft* ( gadget -- )
   dup dup init-cairo swap set-cairo-gadget-cairo-t draw-hello-world ;

M: cairo-gadget ungraft* ( gadget -- )
   cairo-gadget-cairo-t cairo_destroy ;

: <cairo-gadget> ( -- gadget )
  cairo-gadget construct-gadget ;

: run ( -- )
  [
	<cairo-gadget> "Hello World from Factor!" open-window
  ] with-ui ;

MAIN: run
