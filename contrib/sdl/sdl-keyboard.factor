! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl
USING: alien lists namespaces kernel math hashtables
sequences ;

: SDL_EnableUNICODE ( enable -- )
    "int" "sdl" "SDL_EnableUNICODE" [ "int" ] alien-invoke ;

: SDL_DEFAULT_REPEAT_DELAY    500 ;
: SDL_DEFAULT_REPEAT_INTERVAL 30 ;

: SDL_EnableKeyRepeat ( delay interval -- )
    "int" "sdl" "SDL_EnableKeyRepeat" [ "int" "int" ] alien-invoke ;

: modifier ( mod -- str )
    [ modifiers [ uncons rot bitand 0 > ?, ] each-with ] [ ] make ;

: keysym ( sym -- str )
    #! Return the original keysym number if its unknown.
    [ keysyms hash dup ] keep ? ;

: keyboard-event>binding ( event -- binding )
    #! Turn a key event into a binding, which is a list where
    #! all elements but the last one are modifier names looked
    #! up the modifiers alist, and the last element is a keysym
    #! look up in the keysyms hash.
    dup keyboard-event-mod modifier
    swap keyboard-event-sym keysym add ;
