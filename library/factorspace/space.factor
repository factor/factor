! :sidekick.parser=none:

IN: graphics

USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: sdl
USE: stack
USE: vectors
USE: stdio
USE: prettyprint
USE: inspector

SYMBOL: scene
SYMBOL: tool
SYMBOL: current ( shape we're drawing right now )
SYMBOL: moving? ( are we moving or resizing current shape? )
SYMBOL: buttons ( mouse buttons down )
SYMBOL: clicked ( mouse click location )

: ch>tool ( ch -- quot )
    [
        [ CHAR: a ]
        [ CHAR: r <rectangle> ]
        [ CHAR: l <line> ]
    ] assoc ;

: render ( -- )
    clear-surface
    scene get [ draw ] each
    current get [ draw ] when* ;

: mouse-xy ( mouse-event -- #{ x y } )
    dup motion-event-x swap motion-event-y rect> ;

: begin-draw ( #{ x y } -- )
    tool get call [
        dup from set to set
        black color set
    ] extend current set ;

: begin-move ( #{ x y } -- )
    scene get grab
    [ dup scene remove@ current set  moving? on ] when* ;

: button-down ( event -- )
    button-event-button buttons unique@ ;

: mouse-down-event ( event -- )
    dup button-down
    1 buttons get contains? [
        mouse-xy screen>scene tool get [ begin-draw ] [ begin-move ] ifte
    ] [
        drop
    ] ifte ;

: button-up ( event -- )
    button-event-button buttons remove@ ;

: mouse-up-event ( event -- )
    button-up
    current get [
        scene cons@  current off  moving? off
    ] when* ;

: mouse-delta ( mouse-event -- #{ x y } )
    dup motion-event-xrel swap motion-event-yrel rect> ;

: mouse-motion-event ( event -- )
    2 buttons get contains? [
        mouse-delta scale get / origin -@
    ] [
        current get dup [
            [
                moving? get [
                    mouse-delta scale get / dup from +@ to +@
                ] [
                    mouse-xy screen>scene to set
                ] ifte
            ] bind
        ] [
            2drop
        ] ifte
    ] ifte ;

: key-down-event
    keyboard-event-sym [
        [ CHAR: - = ] [ drop 1.1 scale /@ ]
        [ CHAR: = = ] [ drop 1.1 scale *@ ]
        [ drop t ] [ ch>tool tool set ]
    ] cond ;

: debug-event ( event -- ? )
    [
        [ event-type SDL_MOUSEBUTTONDOWN = ] [ mouse-down-event t ]
        [ event-type SDL_MOUSEBUTTONUP = ] [ mouse-up-event t ]
        [ event-type SDL_MOUSEMOTION = ] [ mouse-motion-event t ]
        [ event-type SDL_KEYDOWN = ] [ key-down-event t ]
        [ event-type SDL_QUIT = ] [ drop f ]
        [ drop t ] [ drop t ]
    ] cond ;

: debug-event-loop ( event -- )
    dup SDL_WaitEvent 1 = [
        dup debug-event [
            [ render ] with-surface
            debug-event-loop
        ] [
            drop
        ] ifte
    ] [
        drop
    ] ifte ;

: zui-test ( -- )
    640 480 32 SDL_HWSURFACE SDL_SetVideoMode drop
    1 scale set
    0 origin set
    buttons off
    640 width set
    480 height set

    scene off
    [ <line> ] tool set
    
    <event> debug-event-loop
    SDL_Quit ;

zui-test
