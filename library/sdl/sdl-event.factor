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

BEGIN-ENUM: 0
    ENUM: SDL_NOEVENT         ! Unused (do not remove)
    ENUM: SDL_ACTIVEEVENT     ! Application loses/gains visibility
    ENUM: SDL_KEYDOWN         ! Keys pressed
    ENUM: SDL_KEYUP           ! Keys released
    ENUM: SDL_MOUSEMOTION     ! Mouse moved
    ENUM: SDL_MOUSEBUTTONDOWN ! Mouse button pressed
    ENUM: SDL_MOUSEBUTTONUP   ! Mouse button released
    ENUM: SDL_JOYAXISMOTION   ! Joystick axis motion
    ENUM: SDL_JOYBALLMOTION   ! Joystick trackball motion
    ENUM: SDL_JOYHATMOTION    ! Joystick hat position change
    ENUM: SDL_JOYBUTTONDOWN   ! Joystick button pressed
    ENUM: SDL_JOYBUTTONUP     ! Joystick button released
    ENUM: SDL_QUIT            ! User-requested quit
    ENUM: SDL_SYSWMEVENT      ! System specific event
    ENUM: SDL_EVENT_RESERVEDA ! Reserved for future use..
    ENUM: SDL_EVENT_RESERVEDB ! Reserved for future use..
    ENUM: SDL_VIDEORESIZE     ! User resized video mode
    ENUM: SDL_VIDEOEXPOSE     ! Screen needs to be redrawn
    ENUM: SDL_EVENT_RESERVED2 ! Reserved for future use..
    ENUM: SDL_EVENT_RESERVED3 ! Reserved for future use..
    ENUM: SDL_EVENT_RESERVED4 ! Reserved for future use..
    ENUM: SDL_EVENT_RESERVED5 ! Reserved for future use..
    ENUM: SDL_EVENT_RESERVED6 ! Reserved for future use..
    ENUM: SDL_EVENT_RESERVED7 ! Reserved for future use..
END-ENUM

! Events SDL_USEREVENT through SDL_MAXEVENTS-1 are for your use
: SDL_USEREVENT 24 ;
: SDL_MAXEVENT  32 ;

BEGIN-STRUCT: event
    FIELD: char type
    FIELD: int unused
    FIELD: int unused
    FIELD: int unused
    FIELD: int unused
END-STRUCT

: SDL_WaitEvent ( event -- )
    "int" "sdl" "SDL_WaitEvent" [ "event*" ] alien-call ; compiled
