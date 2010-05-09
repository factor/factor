! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax alien.c-types alien.destructors 
alien.strings alien.libraries arrays classes.struct combinators 
destructors fonts init kernel math math.rectangles memoize 
io.encodings.utf8 system
gir glib glib.ffi ;

<< 
"pango" {
    { [ os winnt? ] [ "libpango-1.0-0.dll" cdecl add-library ] }
    { [ os macosx? ] [ "/opt/local/lib/libpango-1.0.0.dylib" cdecl add-library ] }
    { [ os unix? ] [ drop ] }
} cond 
>>

IN: pango.ffi

TYPEDEF: void PangoLayoutRun ! не совсем верно
TYPEDEF: guint32 PangoGlyph

IN-GIR: pango vocab:pango/Pango-1.0.gir

IN: pango.ffi

FORGET: PangoRectangle

STRUCT: PangoRectangle
    { x int }
    { y int }
    { width int }
    { height int } ;

IN: pango

CONSTANT: PANGO_SCALE 1024

: pango>float ( n -- x ) PANGO_SCALE /f ; inline
: float>pango ( x -- n ) PANGO_SCALE * >integer ; inline

: PangoRectangle>rect ( PangoRectangle -- rect )
    [ [ x>> pango>float ] [ y>> pango>float ] bi 2array ]
    [ [ width>> pango>float ] [ height>> pango>float ] bi 2array ] bi
    <rect> ;

DESTRUCTOR: pango_font_description_free

DESTRUCTOR: pango_layout_iter_free

! перенести в ui.*?
MEMO: (cache-font-description) ( font -- description )
    [
        [ pango_font_description_new |pango_font_description_free ] dip {
            [ name>> utf8 string>alien pango_font_description_set_family ]
            [ size>> float>pango pango_font_description_set_size ]
            [ bold?>> PANGO_WEIGHT_BOLD PANGO_WEIGHT_NORMAL ? pango_font_description_set_weight ]
            [ italic?>> PANGO_STYLE_ITALIC PANGO_STYLE_NORMAL ? pango_font_description_set_style ]
            [ drop ]
        } 2cleave
    ] with-destructors ;

: cache-font-description ( font -- description )
    strip-font-colors (cache-font-description) ;

[ \ (cache-font-description) reset-memoized ] "pango" add-startup-hook

