! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl USING: alien ;

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
