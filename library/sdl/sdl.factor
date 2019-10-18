! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

IN: sdl
USE: alien
USE: compiler

: SDL_INIT_TIMER        HEX: 00000001 ;
: SDL_INIT_AUDIO        HEX: 00000010 ;
: SDL_INIT_VIDEO        HEX: 00000020 ;
: SDL_INIT_CDROM        HEX: 00000100 ;
: SDL_INIT_JOYSTICK     HEX: 00000200 ;
: SDL_INIT_NOPARACHUTE  HEX: 00100000 ;
: SDL_INIT_EVENTTHREAD  HEX: 01000000 ;
: SDL_INIT_EVERYTHING   HEX: 0000FFFF ;

: SDL_Init ( mode -- 0/1 )
    "int" "sdl" "SDL_Init" [ "int" ] alien-invoke ;

: SDL_GetError ( -- error )
    "char*" "sdl" "SDL_GetError" [ ] alien-invoke ;

: SDL_Quit ( -- )
    "void" "sdl" "SDL_Quit" [ ] alien-invoke ;
