! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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

IN: sdl-video
USE: alien
USE: compiler
USE: kernel
USE: math

! These are the currently supported flags for the SDL_surface
! Available for SDL_CreateRGBSurface() or SDL_SetVideoMode()
: SDL_SWSURFACE   HEX: 00000000 ; ! Surface is in system memory
: SDL_HWSURFACE   HEX: 00000001 ; ! Surface is in video memory
: SDL_ASYNCBLIT   HEX: 00000004 ; ! Use asynchronous blits if possible
! Available for SDL_SetVideoMode()
: SDL_ANYFORMAT   HEX: 10000000 ; ! Allow any video depth/pixel-format
: SDL_HWPALETTE   HEX: 20000000 ; ! Surface has exclusive palette
: SDL_DOUBLEBUF   HEX: 40000000 ; ! Set up double-buffered video mode
: SDL_FULLSCREEN  HEX: 80000000 ; ! Surface is a full screen display
: SDL_OPENGL      HEX: 00000002 ; ! Create an OpenGL rendering context
: SDL_OPENGLBLIT  HEX: 0000000A ; ! Create an OpenGL rendering context and use it for blitting
: SDL_RESIZABLE   HEX: 00000010 ; ! This video mode may be resized
: SDL_NOFRAME     HEX: 00000020 ; ! No window caption or edge frame
! Used internally (read-only)
: SDL_HWACCEL     HEX: 00000100 ; ! Blit uses hardware acceleration
: SDL_SRCCOLORKEY HEX: 00001000 ; ! Blit uses a source color key
: SDL_RLEACCELOK  HEX: 00002000 ; ! Private flag
: SDL_RLEACCEL    HEX: 00004000 ; ! Surface is RLE encoded
: SDL_SRCALPHA    HEX: 00010000 ; ! Blit uses source alpha blending
: SDL_PREALLOC    HEX: 01000000 ; ! Surface uses preallocated memory

BEGIN-STRUCT: rect
    FIELD: short x
    FIELD: short y
    FIELD: ushort w
    FIELD: ushort h
END-STRUCT

BEGIN-STRUCT: color
    FIELD: uchar r
    FIELD: uchar g
    FIELD: uchar b
    FIELD: uchar unused
END-STRUCT

BEGIN-STRUCT: format
    FIELD: void* palette
    FIELD: uchar  BitsPerPixel
    FIELD: uchar  BytesPerPixel
    FIELD: uchar  Rloss
    FIELD: uchar  Gloss
    FIELD: uchar  Bloss
    FIELD: uchar  Aloss
    FIELD: uchar  Rshift
    FIELD: uchar  Gshift
    FIELD: uchar  Bshift
    FIELD: uchar  Ashift
    FIELD: uint   Rmask
    FIELD: uint   Gmask
    FIELD: uint   Bmask
    FIELD: uint   Amask
    FIELD: uint   colorkey
    FIELD: uchar  alpha
END-STRUCT

BEGIN-STRUCT: rect
    FIELD: short   clip-x
    FIELD: short   clip-y
    FIELD: ushort   clip-w
    FIELD: ushort   clip-h
END-STRUCT

BEGIN-STRUCT: surface
    FIELD: uint    flags
    FIELD: format* format
    FIELD: int     w
    FIELD: int     h
    FIELD: ushort  pitch
    FIELD: void*   pixels
    FIELD: int     offset
    FIELD: void*   hwdata
    FIELD: short   clip-x
    FIELD: short   clip-y
    FIELD: ushort   clip-w
    FIELD: ushort   clip-h
    FIELD: uint    unused1
    FIELD: uint    locked
    FIELD: int     map
    FIELD: uint    format_version
    FIELD: int     refcount
END-STRUCT

: must-lock-surface? ( surface -- ? )
    #! This is a macro in SDL_video.h.
    dup surface-offset 0 = [
        surface-flags
        SDL_HWSURFACE SDL_ASYNCBLIT bitor SDL_RLEACCEL bitor
        bitand 0 = not
    ] [
        drop t
    ] ifte ;

: SDL_VideoInit ( driver-name flags -- )
    "int" "sdl" "SDL_VideoInit"
    [ "char*" "int" ] alien-invoke ;

: SDL_VideoQuit ( -- )
    "void" "sdl" "SDL_VideoQuit" [ ] alien-invoke ;

! SDL_VideoDriverName -- needs strings as out params.

: SDL_GetVideoSurface ( -- surface )
    "surface*" "sdl" "SDL_GetVideoSurface" [ ] alien-invoke ;

! SDL_GetVideoInfo needs C struct bitfield support

: SDL_VideoModeOK ( width height bpp flags -- )
    "int" "sdl" "SDL_VideoModeOK"
    [ "int" "int" "int" "int" ] alien-invoke ;

! SDL_ListModes needs array of structs support

: SDL_SetVideoMode ( width height bpp flags -- )
    "surface*" "sdl" "SDL_SetVideoMode"
    [ "int" "int" "int" "int" ] alien-invoke ;

! UpdateRects, UpdateRect

: SDL_Flip ( surface -- )
    "bool" "sdl" "SDL_Flip" [ "surface*" ] alien-invoke ;

! SDL_SetGamma: float types

: SDL_MapRGB ( surface r g b -- rgb )
    "uint" "sdl" "SDL_MapRGB"
    [ "surface*" "uchar" "uchar" "uchar" ] alien-invoke ;

: SDL_LockSurface ( surface -- ? )
    "bool" "sdl" "SDL_LockSurface" [ "surface*" ] alien-invoke ;

: SDL_UnlockSurface ( surface -- )
    "void" "sdl" "SDL_UnlockSurface" [ "surface*" ] alien-invoke ;

: SDL_FreeSurface ( surface -- )
    "void" "sdl" "SDL_FreeSurface" [ "surface*" ] alien-invoke ;

: SDL_UpperBlit ( src srcrect dst dstrect -- )
    #! The blit function should not be called on a locked
    #! surface.
    "int" "sdl" "SDL_UpperBlit" [
        "surface*" "rect*"
        "surface*" "rect*"
    ] alien-invoke ;

: SDL_FillRect ( surface rect color -- n )
    #! If rect is null, fills entire surface.
    "bool" "sdl" "SDL_FillRect"
    [ "surface*" "rect*" "uint" ] alien-invoke ;

: SDL_WM_SetCaption ( title icon -- )
    "void" "sdl" "SDL_WM_SetCaption"
    [ "char*" "char*" ] alien-invoke ;
