! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl-ttf
USE: alien

: UNICODE_BOM_NATIVE  HEX: FEFF ;
: UNICODE_BOM_SWAPPED HEX: FFFE ;

: TTF_ByteSwappedUNICODE ( swapped -- )
    "void" "sdl-ttf" "TTF_ByteSwappedUNICODE" [ "int" ] alien-invoke ;

: TTF_Init ( swapped -- )
    "void" "sdl-ttf" "TTF_Init" [ ] alien-invoke ;

: TTF_OpenFont ( file ptsize -- font )
    "void*" "sdl-ttf" "TTF_OpenFont" [ "char*" "int" ] alien-invoke ;

: TTF_OpenFontIndex ( file ptsize index -- font )
    "void*" "sdl-ttf" "TTF_OpenFont" [ "char*" "int" "long" ] alien-invoke ;

: TTF_STYLE_NORMAL    HEX: 00 ;
: TTF_STYLE_BOLD      HEX: 01 ;
: TTF_STYLE_ITALIC    HEX: 02 ;
: TTF_STYLE_UNDERLINE HEX: 04 ;

: TTF_GetFontStyle ( font -- style )
    "int" "sdl-ttf" "TTF_GetFontStyle" [ "void*" ] alien-invoke ;

: TTF_SetFontStyle ( font style -- )
    "void" "sdl-ttf" "TTF_SetFontStyle" [ "void*" "int" ] alien-invoke ;

: TTF_FontHeight ( font -- n )
    "int" "sdl-ttf" "TTF_FontHeight" [ "void*" ] alien-invoke ;

: TTF_FontAscent ( font -- n )
    "int" "sdl-ttf" "TTF_FontAscent" [ "void*" ] alien-invoke ;

: TTF_FontDescent ( font -- n )
    "int" "sdl-ttf" "TTF_FontDescent" [ "void*" ] alien-invoke ;

: TTF_FontLineSkip ( font -- n )
    "int" "sdl-ttf" "TTF_FontLineSkip" [ "void*" ] alien-invoke ;

: TTF_FontFaces ( font -- n )
    "long" "sdl-ttf" "TTF_FontFaces" [ "void*" ] alien-invoke ;

: TTF_FontFaceIsFixedWidth ( font -- ? )
    "bool" "sdl-ttf" "TTF_FontFaceIsFixedWidth" [ "void*" ] alien-invoke ;

: TTF_FontFaceFamilyName ( font -- n )
    "char*" "sdl-ttf" "TTF_FontFaceFamilyName" [ "void*" ] alien-invoke ;

: TTF_FontFaceStyleName ( font -- n )
    "char*" "sdl-ttf" "TTF_FontFaceStyleName" [ "void*" ] alien-invoke ;

BEGIN-STRUCT: int-box
    FIELD: int i
END-STRUCT

: TTF_SizeUNICODE ( font text w h -- ? )
    "bool" "sdl-ttf" "TTF_SizeUNICODE" [ "void*" "ushort*" "int-box*" "int-box*" ] alien-invoke ;

: TTF_RenderUNICODE_Solid ( font text fg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderUNICODE_Solid" [ "void*" "ushort*" "int" ] alien-invoke ;

: TTF_RenderGlyph_Solid ( font text fg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderText_Solid" [ "void*" "ushort" "int" ] alien-invoke ;

: TTF_RenderUNICODE_Shaded ( font text fg bg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderUNICODE_Shaded" [ "void*" "ushort*" "int" "int" ] alien-invoke ;

: TTF_RenderGlyph_Shaded ( font text fg bg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderGlyph_Shaded" [ "void*" "ushort" "int" "int" ] alien-invoke ;

: TTF_RenderUNICODE_Blended ( font text fg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderUNICODE_Blended" [ "void*" "ushort*" "int" ] alien-invoke ;

: TTF_RenderGlyph_Blended ( font text fg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderGlyph_Blended" [ "void*" "ushort" "int" ] alien-invoke ;

: TTF_CloseFont ( font -- )
    "void" "sdl-ttf" "TTF_CloseFont" [ "void*" ] alien-invoke ;

: TTF_Quit ( -- )
    "void" "sdl-ttf" "TTF_CloseFont" [ ] alien-invoke ;

: TTF_WasInit ( -- ? )
    "bool" "sdl-ttf" "TTF_WasInit" [ ] alien-invoke ;
