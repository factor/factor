! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien kernel ;
IN: freetype

windows? [
    "freetype" "freetype6.dll" "cdecl" add-library
] when

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
                    
    FIELD: long     format
                    
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

BEGIN-STRUCT: face-size
    FIELD: face*     face
    FIELD: void*     generic
    FIELD: void*     generic

    FIELD: FT_UShort x-ppem
    FIELD: FT_UShort y-ppem
                     
    FIELD: FT_Fixed  x-scale
    FIELD: FT_Fixed  y-scale
                     
    FIELD: FT_Pos    ascender
    FIELD: FT_Pos    descender
    FIELD: FT_Pos    height
    FIELD: FT_Pos    max-advance
END-STRUCT

BEGIN-STRUCT: face
    FIELD: FT_Long    num-faces
    FIELD: FT_Long    index
                      
    FIELD: FT_Long    flags
    FIELD: FT_Long    style-flags
                      
    FIELD: FT_Long    num-glyphs
                      
    FIELD: FT_Char*   family-name
    FIELD: FT_Char*   style-name
                      
    FIELD: FT_Int     num-fixed-sizes
    FIELD: void*      available-sizes
                      
    FIELD: FT_Int     num-charmaps
    FIELD: void*      charmaps
                      
    FIELD: void*      generic
    FIELD: void*      generic
                      
    FIELD: FT_Pos     x-min
    FIELD: FT_Pos     y-min
    FIELD: FT_Pos     x-max
    FIELD: FT_Pos     y-max
                      
    FIELD: FT_UShort  units-per-em
    FIELD: FT_Short   ascender
    FIELD: FT_Short   descender
    FIELD: FT_Short   height
                      
    FIELD: FT_Short   max-advance-width
    FIELD: FT_Short   max-advance-height
                      
    FIELD: FT_Short   underline-position
    FIELD: FT_Short   underline-thickness
                      
    FIELD: glyph*     glyph
    FIELD: face-size* size
    FIELD: void*      charmap
END-STRUCT

FUNCTION: FT_Error FT_New_Face ( void* library, FT_Char* font, FT_Long index, face* face ) ;

FUNCTION: FT_Error FT_Set_Char_Size ( face* face, FT_F26Dot6 char_width, FT_F26Dot6 char_height, FT_UInt horizontal_dpi, FT_UInt vertical_dpi ) ;

FUNCTION: FT_Error FT_Load_Char ( face* face, FT_ULong charcode, FT_Int32 load_flags ) ;

C-ENUM:
    FT_RENDER_MODE_NORMAL
    FT_RENDER_MODE_LIGHT
    FT_RENDER_MODE_MONO
    FT_RENDER_MODE_LCD
    FT_RENDER_MODE_LCD_V
;

FUNCTION: int FT_Render_Glyph ( glyph* slot, int render_mode ) ;

FUNCTION: void FT_Done_Face ( face* face ) ;

FUNCTION: void FT_Done_FreeType ( void* library ) ;

FUNCTION: FT_Long FT_MulFix ( FT_Long a, FT_Long b ) ;
