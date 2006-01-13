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
            { 600 700 0 } world get set-gadget-dim
            <hand> hand set
            first-time off
        ] when
    ] bind ;

: check-running
    world get [
        world-running?
        [ "The UI is already running" throw ] when
    ] when* ;

IN: shells

: ui ( -- )
    check-running [
        init-world world get rect-dim first2
        [ listener-application run-world ] with-gl-screen
    ] with-freetype ;

IN: gadgets

: ui* [ ui ] in-thread ;
