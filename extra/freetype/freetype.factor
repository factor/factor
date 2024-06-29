! Copyright (C) 2005, 2007 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax kernel system combinators
alien.libraries classes.struct ;
IN: freetype

<< "freetype" {
    { [ os macos? ] [ "libfreetype.6.dylib" cdecl add-library ] }
    { [ os windows? ] [ "freetype6.dll" cdecl add-library ] }
    [ drop ]
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
TYPEDEF: ulong FT_Offset
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

FUNCTION: FT_Error FT_Init_FreeType ( void* library )

! circular reference between glyph and face
C-TYPE: face
C-TYPE: glyph

STRUCT: glyph
    { library void* }
    { face face* }
    { next glyph* }
    { reserved FT_UInt }
    { generic void* }
    { generic2 void* }

    { width FT_Pos }
    { height FT_Pos }

    { hori-bearing-x FT_Pos }
    { hori-bearing-y FT_Pos }
    { hori-advance FT_Pos }

    { vert-bearing-x FT_Pos }
    { vert-bearing-y FT_Pos }
    { vert-advance FT_Pos }

    { linear-hori-advance FT_Fixed }
    { linear-vert-advance FT_Fixed }
    { advance-x FT_Pos }
    { advance-y FT_Pos }

    { format intptr_t }

    { bitmap-rows int }
    { bitmap-width int }
    { bitmap-pitch int }
    { bitmap-buffer void* }
    { bitmap-num-grays short }
    { bitmap-pixel-mode char }
    { bitmap-palette-mode char }
    { bitmap-palette void* }

    { bitmap-left FT_Int }
    { bitmap-top FT_Int }

    { n-contours short }
    { n-points short }

    { points void* }
    { tags c-string }
    { contours short* }

    { outline-flags int }

    { num_subglyphs FT_UInt }
    { subglyphs void* }

    { control-data void* }
    { control-len long }

    { lsb-delta FT_Pos }
    { rsb-delta FT_Pos }

    { other void* } ;

STRUCT: face-size
    { face face* }
    { generic void* }
    { generic2 void* }

    { x-ppem FT_UShort }
    { y-ppem FT_UShort }

    { x-scale FT_Fixed }
    { y-scale FT_Fixed }

    { ascender FT_Pos }
    { descender FT_Pos }
    { height FT_Pos }
    { max-advance FT_Pos } ;

STRUCT: face
    { num-faces FT_Long }
    { index FT_Long }

    { flags FT_Long }
    { style-flags FT_Long }

    { num-glyphs FT_Long }

    { family-name FT_Char* }
    { style-name FT_Char* }

    { num-fixed-sizes FT_Int }
    { available-sizes void* }

    { num-charmaps FT_Int }
    { charmaps void* }

    { generic void* }
    { generic2 void* }

    { x-min FT_Pos }
    { y-min FT_Pos }
    { x-max FT_Pos }
    { y-max FT_Pos }

    { units-per-em FT_UShort }
    { ascender FT_Short }
    { descender FT_Short }
    { height FT_Short }

    { max-advance-width FT_Short }
    { max-advance-height FT_Short }

    { underline-position FT_Short }
    { underline-thickness FT_Short }

    { glyph glyph* }
    { size face-size* }
    { charmap void* } ;

STRUCT: FT_Bitmap
    { rows int }
    { width int }
    { pitch int }
    { buffer void* }
    { num_grays short }
    { pixel_mode char }
    { palette_mode char }
    { palette void* } ;

C-TYPE: FT_Face

FUNCTION: FT_Error FT_New_Face ( void* library, FT_Char* font, FT_Long index, face* face )

FUNCTION: FT_Error FT_New_Memory_Face ( void* library, FT_Byte* file_base, FT_Long file_size, FT_Long face_index, FT_Face* aface )

FUNCTION: FT_Error FT_Set_Char_Size ( face* face, FT_F26Dot6 char_width, FT_F26Dot6 char_height, FT_UInt horizontal_dpi, FT_UInt vertical_dpi )

FUNCTION: FT_Error FT_Load_Char ( face* face, FT_ULong charcode, FT_Int32 load_flags )

CONSTANT: FT_RENDER_MODE_NORMAL 0
CONSTANT: FT_RENDER_MODE_LIGHT 1
CONSTANT: FT_RENDER_MODE_MONO 2
CONSTANT: FT_RENDER_MODE_LCD 3
CONSTANT: FT_RENDER_MODE_LCD_V 4

CONSTANT: FT_PIXEL_MODE_NONE 0
CONSTANT: FT_PIXEL_MODE_MONO 1
CONSTANT: FT_PIXEL_MODE_GRAY 2
CONSTANT: FT_PIXEL_MODE_GRAY2 3
CONSTANT: FT_PIXEL_MODE_GRAY4 4
CONSTANT: FT_PIXEL_MODE_LCD 5
CONSTANT: FT_PIXEL_MODE_LCD_V 6

FUNCTION: int FT_Render_Glyph ( glyph* slot, int render_mode )

FUNCTION: void FT_Done_Face ( face* face )

FUNCTION: void FT_Done_FreeType ( void* library )

FUNCTION: FT_Long FT_MulFix ( FT_Long a, FT_Long b )
