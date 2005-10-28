! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors freetype gadgets-layouts gadgets-listener
gadgets-theme generic help io kernel listener lists math memory
namespaces opengl prettyprint sdl sequences shells styles
threads words ;

SYMBOL: first-time

global [ first-time on ] bind

: init-world ( -- )
    global [
        first-time get [
            <world> world set
            world get solid-interior
            @{ 800 600 0 }@ world get set-gadget-dim
            <hand> hand set
            first-time off
        ] when
    ] bind ;

: check-running
    world get world-running?
    [ "The UI is already running" throw ] when ;

IN: shells

: ui ( -- )
    #! Start the Factor graphics subsystem with the given screen
    #! dimensions.
    [
        init-world check-running
        world get rect-dim first2
        [ listener-application run-world ] with-gl-screen
    ] with-freetype ;
