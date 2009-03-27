! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax kernel system combinators
alien.libraries ;
IN: freetype

<< "freetype" {
    { [ os macosx? ] [ "/usr/X11R6/lib/libfreetype.6.dylib" "cdecl" add-library ] }
    { [ os windows? ] [ "freetype6.dll" "cdecl" add-library ] }
    { [ t ] [ drop ] }
} cond >>

LIBRARY: freetype

TYPEDEF: uchar FT_Byte
TYPEDEF: void* FT_Bytes
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

C-STRUCT: glyph
    { "void*" "library" }
    { "face*" "face" }
    { "glyph*" "next" }
    { "FT_UInt" "reserved" }
    { "void*" "generic" }
    { "void*" "generic" }

    { "FT_Pos" "width" }
    { "FT_Pos" "height" }

    { "FT_Pos" "hori-bearing-x" }
    { "FT_Pos" "hori-bearing-y" }
    { "FT_Pos" "hori-advance" }

    { "FT_Pos" "vert-bearing-x" }
    { "FT_Pos" "vert-bearing-y" }
    { "FT_Pos" "vert-advance" }

    { "FT_Fixed" "linear-hori-advance" }
    { "FT_Fixed" "linear-vert-advance" }
    { "FT_Pos" "advance-x" }
    { "FT_Pos" "advance-y" }

    { "intptr_t" "format" }

    { "int" "bitmap-rows" }
    { "int" "bitmap-width" }
    { "int" "bitmap-pitch" }
    { "void*" "bitmap-buffer" }
    { "short" "bitmap-num-grays" }
    { "char" "bitmap-pixel-mode" }
    { "char" "bitmap-palette-mode" }
    { "void*" "bitmap-palette" }

    { "FT_Int" "bitmap-left" }
    { "FT_Int" "bitmap-top" }

    { "short" "n-contours" }
    { "short" "n-points" }

    { "void*" "points" }
    { "char*" "tags" }
    { "short*" "contours" }

    { "int" "outline-flags" }

    { "FT_UInt" "num_subglyphs" }
    { "void*" "subglyphs" }

    { "void*" "control-data" }
    { "long" "control-len" }

    { "FT_Pos" "lsb-delta" }
    { "FT_Pos" "rsb-delta" }

    { "void*" "other" } ;

C-STRUCT: face-size
    { "face*" "face" }
    { "void*" "generic" }
    { "void*" "generic" }

    { "FT_UShort" "x-ppem" }
    { "FT_UShort" "y-ppem" }

    { "FT_Fixed" "x-scale" }
    { "FT_Fixed" "y-scale" }

    { "FT_Pos" "ascender" }
    { "FT_Pos" "descender" }
    { "FT_Pos" "height" }
    { "FT_Pos" "max-advance" } ;

C-STRUCT: face
    { "FT_Long" "num-faces" }
    { "FT_Long" "index" }

    { "FT_Long" "flags" }
    { "FT_Long" "style-flags" }

    { "FT_Long" "num-glyphs" }

    { "FT_Char*" "family-name" }
    { "FT_Char*" "style-name" }

    { "FT_Int" "num-fixed-sizes" }
    { "void*" "available-sizes" }

    { "FT_Int" "num-charmaps" }
    { "void*" "charmaps" }

    { "void*" "generic" }
    { "void*" "generic" }

    { "FT_Pos" "x-min" }
    { "FT_Pos" "y-min" }
    { "FT_Pos" "x-max" }
    { "FT_Pos" "y-max" }

    { "FT_UShort" "units-per-em" }
    { "FT_Short" "ascender" }
    { "FT_Short" "descender" }
    { "FT_Short" "height" }

    { "FT_Short" "max-advance-width" }
    { "FT_Short" "max-advance-height" }

    { "FT_Short" "underline-position" }
    { "FT_Short" "underline-thickness" }

    { "glyph*" "glyph" }
    { "face-size*" "size" }
    { "void*" "charmap" } ;

C-STRUCT: FT_Bitmap
    { "int" "rows" }
    { "int" "width" }
    { "int" "pitch" }
    { "void*" "buffer" }
    { "short" "num_grays" }
    { "char" "pixel_mode" }
    { "char" "palette_mode" }
    { "void*" "palette" } ;

FUNCTION: FT_Error FT_New_Face ( void* library, FT_Char* font, FT_Long index, face* face ) ;

FUNCTION: FT_Error FT_New_Memory_Face ( void* library, FT_Byte* file_base, FT_Long file_size, FT_Long face_index, FT_Face* aface ) ;

FUNCTION: FT_Error FT_Set_Char_Size ( face* face, FT_F26Dot6 char_width, FT_F26Dot6 char_height, FT_UInt horizontal_dpi, FT_UInt vertical_dpi ) ;

FUNCTION: FT_Error FT_Load_Char ( face* face, FT_ULong charcode, FT_Int32 load_flags ) ;

C-ENUM:
    FT_RENDER_MODE_NORMAL
    FT_RENDER_MODE_LIGHT
    FT_RENDER_MODE_MONO
    FT_RENDER_MODE_LCD
    FT_RENDER_MODE_LCD_V ;

C-ENUM:
    FT_PIXEL_MODE_NONE
    FT_PIXEL_MODE_MONO
    FT_PIXEL_MODE_GRAY
    FT_PIXEL_MODE_GRAY2
    FT_PIXEL_MODE_GRAY4
    FT_PIXEL_MODE_LCD
    FT_PIXEL_MODE_LCD_V ;

FUNCTION: int FT_Render_Glyph ( glyph* slot, int render_mode ) ;

FUNCTION: void FT_Done_Face ( face* face ) ;

FUNCTION: void FT_Done_FreeType ( void* library ) ;

FUNCTION: FT_Long FT_MulFix ( FT_Long a, FT_Long b ) ;

