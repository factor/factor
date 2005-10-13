! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien arrays errors hashtables io kernel lists math
namespaces sequences styles ;
IN: freetype

! Some code to render TrueType fonts with OpenGL.

LIBRARY: freetype

TYPEDEF: uchar FT_Byte
TYPEDEF: uchar* FT_Bytes
TYPEDEF: char FT_Char
TYPEDEF: int FT_Int
TYPEDEF: int FT_Int32
TYPEDEF: uint FT_UInt
TYPEDEF: short FT_Short
TYPEDEF: ushort FT_UShort
TYPEDEF: long FT_Long
TYPEDEF: ulong FT_ULong
TYPEDEF: uchar FT_Bool
TYPEDEF: cell FT_Offset
TYPEDEF: int FT_PtrDist
TYPEDEF: char FT_String
TYPEDEF: int FT_Tag
TYPEDEF: int FT_Error
TYPEDEF: long FT_Fixed
TYPEDEF: void* FT_Pointer
TYPEDEF: long FT_Pos
TYPEDEF: ushort FT_UFWord
TYPEDEF: short FT_F2Dot14
TYPEDEF: long FT_F26Dot6

FUNCTION: FT_Error FT_Init_FreeType ( void* library ) ;

BEGIN-STRUCT: bitmap
    FIELD: int     rows
    FIELD: int     width
    FIELD: int     pitch
    FIELD: uchar*  buffer
    FIELD: short   num-grays
    FIELD: char    pixel-mode
    FIELD: char    palette-mode
    FIELD: void*   palette
END-STRUCT

! circular reference between glyph and face
TYPEDEF: void face
TYPEDEF: void glyph

BEGIN-STRUCT: glyph
    FIELD: void*    library
    FIELD: face*    face
    FIELD: glyph*   next
    FIELD: FT_UInt  reserved
    FIELD: void*    generic
    FIELD: void*    generic

    FIELD: FT_Pos   width
    FIELD: FT_Pos   height
                  
    FIELD: FT_Pos   hori-bearing-x
    FIELD: FT_Pos   hori-bearing-y
    FIELD: FT_Pos   hori-advance
                  
    FIELD: FT_Pos   vert-bearing-x
    FIELD: FT_Pos   vert-bearing-y
    FIELD: FT_Pos   vert-advance

    FIELD: FT_Fixed linear-hori-advance
    FIELD: FT_Fixed linear-vert-advance
    FIELD: FT_Pos   advance-x
    FIELD: FT_Pos   advance-y
                    
    FIELD: int      format
                    
    FIELD: int      bitmap-rows
    FIELD: int      bitmap-width
    FIELD: int      bitmap-pitch
    FIELD: uchar*   bitmap-buffer
    FIELD: short    bitmap-num-grays
    FIELD: char     bitmap-pixel-mode
    FIELD: char     bitmap-palette-mode
    FIELD: void*    bitmap-palette

    FIELD: FT_Int   bitmap-left
    FIELD: FT_Int   bitmap-top

    FIELD: short    n-contours
    FIELD: short    n-points

    FIELD: void*    points
    FIELD: char*    tags
    FIELD: short*   contours

    FIELD: int      outline-flags
                    
    FIELD: FT_UInt  num_subglyphs
    FIELD: void*    subglyphs
                    
    FIELD: void*    control-data
    FIELD: long     control-len
                    
    FIELD: FT_Pos   lsb-delta
    FIELD: FT_Pos   rsb-delta
                    
    FIELD: void*    other
END-STRUCT

BEGIN-STRUCT: face
    FIELD: FT_Long   num-faces
    FIELD: FT_Long   index
                     
    FIELD: FT_Long   flags
    FIELD: FT_Long   style-flags
                     
    FIELD: FT_Long   num-glyphs
                     
    FIELD: FT_Char*  family-name
    FIELD: FT_Char*  style-name
                     
    FIELD: FT_Int    num-fixed-sizes
    FIELD: void*     available-sizes
                     
    FIELD: FT_Int    num-charmaps
    FIELD: void*     charmaps
                     
    FIELD: void*     generic
    FIELD: void*     generic
                     
    FIELD: FT_Pos    x-min
    FIELD: FT_Pos    y-min
    FIELD: FT_Pos    x-max
    FIELD: FT_Pos    y-max
    
    FIELD: FT_UShort units-per-em
    FIELD: FT_Short  ascender
    FIELD: FT_Short  descender
    FIELD: FT_Short  height
                     
    FIELD: FT_Short  max-advance-width
    FIELD: FT_Short  max-advance-height
                     
    FIELD: FT_Short  underline-position
    FIELD: FT_Short  underline-thickness
    
    FIELD: glyph*    glyph
    FIELD: void*     size
    FIELD: void*     charmap
END-STRUCT

FUNCTION: FT_Error FT_New_Face ( void* library, FT_Char* font, FT_Long index, face* face ) ;

FUNCTION: FT_Error FT_Set_Char_Size ( face* face, FT_F26Dot6 char_width, FT_F26Dot6 char_height, FT_UInt horizontal_dpi, FT_UInt vertical_dpi ) ;

FUNCTION: FT_Error FT_Load_Char ( face* face, FT_ULong charcode, FT_Int32 load_flags ) ;

BEGIN-ENUM: 0
    ENUM: FT_RENDER_MODE_NORMAL
    ENUM: FT_RENDER_MODE_LIGHT
    ENUM: FT_RENDER_MODE_MONO
    ENUM: FT_RENDER_MODE_LCD
    ENUM: FT_RENDER_MODE_LCD_V
END-ENUM

FUNCTION: int FT_Render_Glyph ( glyph* slot, int render_mode ) ;

FUNCTION: void FT_Done_Face ( face* face ) ;

FUNCTION: void FT_Done_FreeType ( void* library ) ;

SYMBOL: freetype

: freetype-error ( n -- ) 0 = [ "FreeType error" throw ] unless ;

SYMBOL: open-fonts

TUPLE: font handle glyphs ;

C: font ( handle -- font )
    { } clone over set-font-glyphs
    [ set-font-handle ] keep ;

: init-freetype ( -- )
    global [
        f <void*> dup FT_Init_FreeType freetype-error
        *void* freetype set
        {{ }} clone open-fonts set
    ] bind ;

: close-freetype ( -- )
    global [
        open-fonts get hash-values [ font-handle FT_Done_Face ] each
        open-fonts off
        freetype get FT_Done_FreeType
    ] bind ;

: with-freetype ( quot -- )
    init-freetype [ close-freetype ] cleanup ; inline

: ttf-name ( font style -- name )
    cons {{
        [[ [[ "Monospaced" plain       ]] "VeraMono" ]]
        [[ [[ "Monospaced" bold        ]] "VeraMoBd" ]]
        [[ [[ "Monospaced" bold-italic ]] "VeraMoBI" ]]
        [[ [[ "Monospaced" italic      ]] "VeraMoIt" ]]
        [[ [[ "Sans Serif" plain       ]] "Vera"     ]]
        [[ [[ "Sans Serif" bold        ]] "VeraBd"   ]]
        [[ [[ "Sans Serif" bold-italic ]] "VeraBI"   ]]
        [[ [[ "Sans Serif" italic      ]] "VeraIt"   ]]
        [[ [[ "Serif" plain            ]] "VeraSe"   ]]
        [[ [[ "Serif" bold             ]] "VeraSeBd" ]]
        [[ [[ "Serif" bold-italic      ]] "VeraBI"   ]]
        [[ [[ "Serif" italic           ]] "VeraIt"   ]]
    }} hash ;

: ttf-path ( name -- string )
    [ "/fonts/" % % ".ttf" % ] "" make resource-path ;

: open-face ( font style -- face )
    #! Open a TrueType font with the given logical name and
    #! style.
    ttf-name ttf-path >r freetype get r>
    0 f <void*> [ FT_New_Face freetype-error ] keep *void* ;

: dpi 100 ;

: open-font ( { font style ptsize } -- font )
    #! Open a font and set the point size of the font.
    first3 >r open-face dup 0 r> 6 shift
    dpi dpi FT_Set_Char_Size freetype-error <font> ;

: lookup-font ( font style ptsize -- font )
    #! Cache open fonts.
    3array open-fonts get [ open-font ] cache ;

: render-glyph ( face char -- bitmap )
    #! Render a character and return a pointer to the bitmap.
    dupd 0 FT_Load_Char freetype-error face-glyph dup
    FT_RENDER_MODE_NORMAL FT_Render_Glyph freetype-error ;

: copy-row ( width texture bitmap row -- )
    #! Copy a row of the bitmap to the texture.
    2drop 2drop ;

: <glyph-texture> ( bitmap -- texture )
    dup glyph-bitmap-width next-power-of-2
    swap glyph-bitmap-rows next-power-of-2 * <c-object> ;

: copy-glyph ( bitmap texture -- )
    #! Copy a bitmap into a texture whose width/height are
    #! the width/height of the bitmap rounded up to the nearest
    #! power of 2.
    >r [ bitmap-width next-power-of-2 ] keep r>
    over bitmap-rows [ >r 3dup r> copy-row ] each 3drop ;

: glyph>texture ( bitmap -- texture )
    #! Given a glyph bitmap, copy it to a texture whose size is
    #! a power of two.
    dup <glyph-texture> [ copy-glyph ] keep ;
