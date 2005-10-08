! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors gadgets-layouts gadgets-listener gadgets-theme generic
help io kernel listener lists math memory namespaces prettyprint
sdl sequences shells styles threads words ;

: init-world
    global [
        world get clear-gadget
        <gadget> dup solid-interior add-layer
        listener-application
    ] bind ;

SYMBOL: first-time

global [
    <world> world set
    world get world-theme
    <hand> hand set
    @{ 800 600 0 }@ world get set-gadget-dim
    first-time on 
] bind

: ?init-world
    first-time get [ init-world first-time off ] when ;

: check-running
    world get [
        dup world-running?
        [ "The UI is already running" throw ] when
    ] when* ;

IN: shells

: ui ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    check-running
    world get rect-dim first2 0 SDL_RESIZABLE
    [ ?init-world run-world ] with-screen ;
