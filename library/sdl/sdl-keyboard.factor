! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms ; with or without
! modification ; are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice ;
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice ;
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES ;
! INCLUDING ; BUT NOT LIMITED TO ; THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT ; INDIRECT ; INCIDENTAL ;
! SPECIAL ; EXEMPLARY ; OR CONSEQUENTIAL DAMAGES (INCLUDING ; BUT NOT LIMITED TO ;
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE ; DATA ; OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY ;
! WHETHER IN CONTRACT ; STRICT LIABILITY ; OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE ; EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: sdl-keyboard
USE: alien
USE: lists
USE: sdl-keysym
USE: namespaces
USE: sdl-event
USE: kernel
USE: math
USE: hashtables

: SDL_EnableUNICODE ( enable -- )
    "int" "sdl" "SDL_EnableUNICODE" [ "int" ] alien-invoke ;

: SDL_DEFAULT_REPEAT_DELAY    500 ;
: SDL_DEFAULT_REPEAT_INTERVAL 30 ;

: SDL_EnableKeyRepeat ( delay interval -- )
    "int" "sdl" "SDL_EnableKeyRepeat" [ "int" "int" ] alien-invoke ;

: modifiers, ( mod -- )
    modifiers get [
        uncons pick bitand 0 = [ drop ] [ unique, ] ifte
    ] each
    drop ;

: keysym, ( sym -- )
    #! Return the original keysym number if its unknown.
    [ keysyms get hash dup ] keep ? , ;

: keyboard-event>binding ( event -- binding )
    #! Turn a key event into a binding, which is a list where
    #! all elements but the last one are modifier names looked
    #! up the modifiers alist, and the last element is a keysym
    #! look up in the keysyms hash.
    [
        dup keyboard-event-mod modifiers,
        keyboard-event-sym keysym,
    ] make-list ;
