! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences alien alien.c-types alien.destructors
alien.syntax math math.functions math.vectors destructors combinators
colors fonts accessors assocs namespaces kernel pango pango.fonts
glib unicode.data images cache init
math.rectangles fry memoize io.encodings.utf8 classes.struct ;
IN: pango.layouts

LIBRARY: pango

C-TYPE: PangoLayout
C-TYPE: PangoLayoutIter
C-TYPE: PangoLayoutLine

FUNCTION: PangoLayout*
pango_layout_new ( PangoContext* context ) ;

FUNCTION: PangoContext*
pango_layout_get_context ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_set_text ( PangoLayout* layout, char* text, int length ) ;

FUNCTION: char*
pango_layout_get_text ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_get_size ( PangoLayout* layout, int* width, int* height ) ;

FUNCTION: void
pango_layout_set_font_description ( PangoLayout* layout, PangoFontDescription* desc ) ;

FUNCTION: PangoFontDescription*
pango_layout_get_font_description ( PangoLayout* layout ) ;

FUNCTION: void
pango_layout_get_pixel_size ( PangoLayout* layout, int* width, int* height ) ;

FUNCTION: void
pango_layout_get_extents ( PangoLayout* layout, PangoRectangle* ink_rect, PangoRectangle* logical_rect ) ;

FUNCTION: void
pango_layout_get_pixel_extents ( PangoLayout* layout, PangoRectangle* ink_rect, PangoRectangle* logical_rect ) ;

FUNCTION: PangoLayoutLine*
pango_layout_get_line_readonly ( PangoLayout* layout, int line ) ;
                                                         
FUNCTION: void
pango_layout_line_index_to_x ( PangoLayoutLine* line, int index_, uint trailing, int* x_pos ) ;

FUNCTION: gboolean
pango_layout_line_x_to_index ( PangoLayoutLine* line, int x_pos, int* index_, int* trailing ) ;

FUNCTION: PangoLayoutIter*
pango_layout_get_iter ( PangoLayout* layout ) ;

FUNCTION: int
pango_layout_iter_get_baseline ( PangoLayoutIter* iter ) ;

FUNCTION: void
pango_layout_iter_free ( PangoLayoutIter* iter ) ;

DESTRUCTOR: pango_layout_iter_free

