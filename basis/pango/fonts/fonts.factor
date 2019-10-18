! Copyright (C) 2008 Matthew Willis.
! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: pango alien.syntax alien.c-types alien.destructors
kernel glib accessors combinators destructors init fonts
memoize math ;
IN: pango.fonts

LIBRARY: pango

ENUM: PangoStyle
PANGO_STYLE_NORMAL
PANGO_STYLE_OBLIQUE
PANGO_STYLE_ITALIC ;

TYPEDEF: int PangoWeight
C-TYPE: PangoFont
C-TYPE: PangoFontFamily
C-TYPE: PangoFontFace
C-TYPE: PangoFontMap
C-TYPE: PangoFontMetrics
C-TYPE: PangoFontDescription
C-TYPE: PangoGlyphString
C-TYPE: PangoLanguage

CONSTANT: PANGO_WEIGHT_THIN 100
CONSTANT: PANGO_WEIGHT_ULTRALIGHT 200
CONSTANT: PANGO_WEIGHT_LIGHT 300
CONSTANT: PANGO_WEIGHT_BOOK 380
CONSTANT: PANGO_WEIGHT_NORMAL 400
CONSTANT: PANGO_WEIGHT_MEDIUM 500
CONSTANT: PANGO_WEIGHT_SEMIBOLD 600
CONSTANT: PANGO_WEIGHT_BOLD 700
CONSTANT: PANGO_WEIGHT_ULTRABOLD 800
CONSTANT: PANGO_WEIGHT_HEAVY 900
CONSTANT: PANGO_WEIGHT_ULTRAHEAVY 1000

FUNCTION: PangoFontDescription*
pango_font_description_new ( ) ;

FUNCTION: void
pango_font_description_free ( PangoFontDescription* desc ) ;

DESTRUCTOR: pango_font_description_free

FUNCTION: PangoFontDescription*
pango_font_description_from_string ( c-string str ) ;

FUNCTION: c-string
pango_font_description_to_string ( PangoFontDescription* desc ) ;

FUNCTION: c-string
pango_font_description_to_filename ( PangoFontDescription* desc ) ;

FUNCTION: void
pango_font_description_set_family ( PangoFontDescription* desc, c-string family ) ;

FUNCTION: void
pango_font_description_set_style ( PangoFontDescription* desc, PangoStyle style ) ;

FUNCTION: void
pango_font_description_set_weight ( PangoFontDescription* desc, PangoWeight weight ) ;

FUNCTION: void
pango_font_description_set_size ( PangoFontDescription* desc, gint size ) ;

FUNCTION: void
pango_font_map_list_families ( PangoFontMap* fontmap, PangoFontFamily*** families, int* n_families ) ;

FUNCTION: c-string
pango_font_family_get_name ( PangoFontFamily* family ) ;

FUNCTION: int
pango_font_family_is_monospace ( PangoFontFamily* family ) ;

FUNCTION: void
pango_font_family_list_faces ( PangoFontFamily* family, PangoFontFace*** faces, int* n_faces ) ;

FUNCTION: c-string
pango_font_face_get_face_name ( PangoFontFace* face ) ;

FUNCTION: void
pango_font_face_list_sizes ( PangoFontFace* face, int** sizes, int* n_sizes ) ;

FUNCTION: void pango_font_metrics_unref ( PangoFontMetrics* metrics ) ;

DESTRUCTOR: pango_font_metrics_unref

FUNCTION: int pango_font_metrics_get_ascent ( PangoFontMetrics* metrics ) ;

FUNCTION: int pango_font_metrics_get_descent ( PangoFontMetrics* metrics ) ;

FUNCTION: PangoFont* pango_font_map_load_font ( PangoFontMap* fontmap, PangoContext* context, PangoFontDescription* desc ) ;

FUNCTION: PangoFontMetrics* pango_context_get_metrics ( PangoContext* context, PangoFontDescription* desc, PangoLanguage* language ) ;

FUNCTION: PangoFontMetrics* pango_font_get_metrics ( PangoFont* font, PangoLanguage* language ) ;
                                                         
MEMO: (cache-font-description) ( font -- description )
    [
        [ pango_font_description_new |pango_font_description_free ] dip {
            [ name>> pango_font_description_set_family ]
            [ size>> float>pango pango_font_description_set_size ]
            [ bold?>> PANGO_WEIGHT_BOLD PANGO_WEIGHT_NORMAL ? pango_font_description_set_weight ]
            [ italic?>> PANGO_STYLE_ITALIC PANGO_STYLE_NORMAL ? pango_font_description_set_style ]
            [ drop ]
        } 2cleave
    ] with-destructors ;

: cache-font-description ( font -- description )
    strip-font-colors (cache-font-description) ;

[ \ (cache-font-description) reset-memoized ] "pango.fonts" add-startup-hook
