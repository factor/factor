! :folding=indent:collapseFolds=1:sidekick.parser=none:

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

IN: sdl-event
USE: alien
USE: generic
USE: kernel

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

: SDL_ACTIVEEVENTMASK     2      ;
: SDL_KEYDOWNMASK         4      ;
: SDL_KEYUPMASK           8      ;
: SDL_MOUSEMOTIONMASK     16     ;
: SDL_MOUSEBUTTONDOWNMASK 32     ;
: SDL_MOUSEBUTTONUPMASK   64     ;
: SDL_MOUSEEVENTMASK      112    ;
: SDL_JOYAXISMOTIONMASK   128    ;
: SDL_JOYBALLMOTIONMASK   256    ;
: SDL_JOYHATMOTIONMASK    512    ;
: SDL_JOYBUTTONDOWNMASK   1024   ;
: SDL_JOYBUTTONUPMASK	  2048   ;
: SDL_JOYEVENTMASK	      3968   ;
: SDL_VIDEORESIZEMASK	  65536  ;
: SDL_VIDEOEXPOSEMASK	  131072 ;
: SDL_QUITMASK		      4096   ;
: SDL_SYSWMEVENTMASK	  8192   ;

: SDL_ALLEVENTS           HEX: ffffffff ;

BEGIN-STRUCT: active-event
    FIELD: uchar type  ! SDL_ACTIVEEVENT
    FIELD: uchar gain  ! Whether given states were gained or lost (1/0)
    FIELD: uchar state ! A mask of the focus states
END-STRUCT

BEGIN-STRUCT: keyboard-event
    FIELD: uchar type  ! SDL_KEYDOWN or SDL_KEYUP
    FIELD: uchar which ! The keyboard device index
    FIELD: uchar state ! SDL_PRESSED or SDL_RELEASED
    ! YUCK!
    FIELD: uchar pad
    FIELD: uchar pad
    FIELD: uchar pad
    ! Later: inline structs
    FIELD: uchar scancode
    FIELD: int sym
    FIELD: int mod
    FIELD: ushort unicode
END-STRUCT

PREDICATE: alien key-down-event
    keyboard-event-type SDL_KEYDOWN = ;

PREDICATE: alien key-up-event
    keyboard-event-type SDL_KEYUP = ;

BEGIN-STRUCT: motion-event
    FIELD: uchar type  ! SDL_MOUSEMOTION
    FIELD: uchar which ! The mouse device index
    FIELD: uchar state ! The current button state
    FIELD: ushort x    ! The X/Y coordinates of the mouse
    FIELD: ushort y
    FIELD: short xrel  ! The relative motion in the X direction
    FIELD: short yrel  ! The relative motion in the Y direction 
END-STRUCT

PREDICATE: alien motion-event
    motion-event-type SDL_MOUSEMOTION = ;

BEGIN-STRUCT: button-event
	FIELD: uchar type    ! SDL_MOUSEBUTTONDOWN or SDL_MOUSEBUTTONUP
	FIELD: uchar which   ! The mouse device index
	FIELD: uchar button  ! The mouse button index
	FIELD: uchar state   ! SDL_PRESSED or SDL_RELEASED
	FIELD: ushort x
    FIELD: ushort y      ! The X/Y coordinates of the mouse at press time
END-STRUCT

PREDICATE: alien button-down-event
    button-event-type SDL_MOUSEBUTTONDOWN = ;

PREDICATE: alien button-up-event
    button-event-type SDL_MOUSEBUTTONUP = ;

BEGIN-STRUCT: joy-axis-event
	FIELD: uchar type   ! SDL_JOYAXISMOTION
    FIELD: uchar which  ! The joystick device index
    FIELD: uchar axis   ! The joystick axis index
    FIELD: short value  ! The axis value
END-STRUCT

PREDICATE: alien joy-axis-event
    joy-axis-event-type SDL_JOYAXISMOTION = ;

BEGIN-STRUCT: joy-ball-event
    FIELD: uchar type  ! SDL_JOYBALLMOTION
    FIELD: uchar which ! The joystick device index
    FIELD: uchar ball  ! The joystick trackball index
    FIELD: short xrel  ! The relative motion in the X direction
    FIELD: short yrel  ! The relative motion in the Y direction
END-STRUCT

PREDICATE: alien joy-ball-event
    joy-ball-event-type SDL_JOYBALLMOTION = ;

BEGIN-STRUCT: joy-hat-event
    FIELD: uchar type  ! SDL_JOYHATMOTION
    FIELD: uchar which ! The joystick device index
    FIELD: uchar hat   ! The joystick hat index
    FIELD: uchar value ! The hat position value:
        ! SDL_HAT_LEFTUP   SDL_HAT_UP       SDL_HAT_RIGHTUP
        ! SDL_HAT_LEFT     SDL_HAT_CENTERED SDL_HAT_RIGHT
        ! SDL_HAT_LEFTDOWN SDL_HAT_DOWN     SDL_HAT_RIGHTDOWN
        ! Note that zero means the POV is centered.
END-STRUCT

PREDICATE: alien joy-hat-event
    joy-hat-event-type SDL_JOYHATMOTION = ;

BEGIN-STRUCT: joy-button-event
	FIELD: uchar type   ! SDL_JOYBUTTONDOWN or SDL_JOYBUTTONUP
	FIELD: uchar which  ! The joystick device index
	FIELD: uchar button ! The joystick button index
	FIELD: uchar state  ! SDL_PRESSED or SDL_RELEASED
END-STRUCT

PREDICATE: alien joy-button-down-event
    joy-button-event-type SDL_JOYBUTTONDOWN = ;

PREDICATE: alien joy-button-up-event
    joy-button-event-type SDL_JOYBUTTONUP = ;

BEGIN-STRUCT: resize-event
    FIELD: uchar type ! SDL_VIDEORESIZE
    FIELD: int w      ! New width
    FIELD: int h      ! New height
END-STRUCT

BEGIN-STRUCT: expose-event
    FIELD: uchar type ! SDL_VIDEOEXPOSE
END-STRUCT

PREDICATE: alien resize-event
    resize-event-type SDL_VIDEORESIZE = ;

BEGIN-STRUCT: quit-event
    FIELD: uchar type ! SDL_QUIT
END-STRUCT

PREDICATE: alien quit-event
    quit-event-type SDL_QUIT = ;

BEGIN-STRUCT: user-event
    FIELD: uchar type ! SDL_USREVENT through SDL_NUMEVENTS-1
    FIELD: int code
    FIELD: void* data1
    FIELD: void* data2
END-STRUCT

PREDICATE: alien user-event
    user-event-type SDL_QUIT = ;

BEGIN-STRUCT: event
    FIELD: uchar type
END-STRUCT

BEGIN-UNION: event
    MEMBER: event
    MEMBER: active-event
    MEMBER: keyboard-event
    MEMBER: motion-event
    MEMBER: button-event
    MEMBER: joy-axis-event
    MEMBER: joy-ball-event
    MEMBER: joy-hat-event
    MEMBER: joy-button-event
    MEMBER: resize-event
    MEMBER: expose-event
    MEMBER: quit-event
    MEMBER: user-event
END-UNION

: SDL_WaitEvent ( event -- )
    "int" "sdl" "SDL_WaitEvent" [ "event*" ] alien-invoke ;

: SDL_PollEvent ( event -- ? )
    "bool" "sdl" "SDL_PollEvent" [ "event*" ] alien-invoke ;
