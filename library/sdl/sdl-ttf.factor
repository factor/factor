! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2005 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

: TTF_RenderText_Solid ( font text fg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderText_Solid" [ "void*" "char*" "int" ] alien-invoke ;

: TTF_RenderGlyph_Shaded ( font text fg bg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderGlyph_Shaded" [ "void*" "ushort" "int" "int" ] alien-invoke ;

: TTF_RenderText_Blended ( font text fg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderText_Blended" [ "void*" "ushort" "int" "int" ] alien-invoke ;

: TTF_RenderGlyph_Blended ( font text fg -- surface )
    "surface*" "sdl-ttf" "TTF_RenderGlyph_Blended" [ "void*" "ushort" "int" ] alien-invoke ;

: TTF_CloseFont ( font -- )
    "void" "sdl-ttf" "TTF_CloseFont" [ "void*" ] alien-invoke ;

: TTF_Quit ( -- )
    "void" "sdl-ttf" "TTF_CloseFont" [ ] alien-invoke ;

: TTF_WasInit ( -- ? )
    "bool" "sdl-ttf" "TTF_WasInit" [ ] alien-invoke ;
