! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar combinators destructors
formatting kernel make math namespaces opengl opengl.textures
sequences sets snake-game.constants snake-game.game
snake-game.input snake-game.util snake-game.sprites timers
ui ui.gadgets ui.gadgets.worlds ui.gestures ui.render ;

FROM: snake-game.util => screen-loc ;
FROM: snake-game.util => relative-loc ;

IN: snake-game.ui

SYMBOL: game-textures

TUPLE: snake-gadget < gadget
    snake-game timer textures ;

: start-new-game ( snake-gadget -- )
    <snake-game> >>snake-game drop ;

: <snake-gadget> ( -- snake-gadget )
    snake-gadget new
    [ start-new-game ] keep ;

: lookup-texture ( key -- texture )
    game-textures get at ;

: draw-sprite* ( key screen-loc -- )
    [ lookup-texture draw-texture ] with-translation ;

: draw-sprite ( grid-loc key -- )
    swap screen-loc draw-sprite* ;

: draw-food ( loc -- )
    "food" draw-sprite ;

: draw-background ( -- )
    { 0 0 } "background" draw-sprite ;

: draw-snake-head ( loc facing-dir -- )
    dup name>> rest "head-" prepend
    [
        [ screen-loc ] dip
        {
            { :right [ { -20 -10 } ] }
            { :down  [ { -10 -20 } ] }
            { :up    [ { -10  0  } ] }
            { :left  [ {  0  -10 } ] }
        } case offset
    ] dip
    swap draw-sprite* ;

: draw-snake-body ( loc from-dir to-dir -- )
    [ name>> rest ] bi@ "body-%s-%s" sprintf draw-sprite ;

: draw-snake-tail ( loc facing-dir -- )
    name>> rest "tail-" prepend draw-sprite ;

: draw-snake-part ( loc from-dir snake-part -- )
    dup type>> {
        { :head [ drop opposite-dir draw-snake-head ] }
        { :body [ dir>> draw-snake-body ] }
        { :tail [ drop draw-snake-tail ] }
    } case ;

: next-snake-loc-from-dir ( loc from-dir snake-part -- new-loc new-from-dir )
    nip dir>> [ relative-loc ] keep ;

: draw-snake ( loc from-dir snake -- )
    3dup [
        [ draw-snake-part ]
        [ next-snake-loc-from-dir ] 3bi
    ] each 2drop
    ! make sure to draw the head again
    first draw-snake-part ;

: generate-status-message ( snake-game -- str )
    [ score>> "Score: %d" sprintf ]
    [
        {
            { [ dup game-over?>> ] [ drop "Game Over" ] }
            { [ dup paused?>> ] [ drop "Game Paused" ] }
            [ drop "Game In Progress" ]
        } cond
    ]
    bi 2array " -- " join ;
        
: update-status ( gadget -- )
    [ snake-game>> generate-status-message ] keep show-status ;

: do-updates ( gadget -- )
    [ snake-game>> do-game-step ]
    [ update-status ]
    [ relayout-1 ]
    tri ;

: toggle-game-pause ( snake-gadget -- )
    snake-game>> [ not ] change-paused? drop ;

: ?handle-movement-key ( snake-game key -- )
    key-action
    [
        2dup [ snake-dir>> opposite-dir ] dip =
        [ 2drop ] [ >>next-turn-dir drop ] if
    ] [ drop ] if* ;

: handle-key ( snake-gadget key -- )
    {
        { [ dup quit-key? ] [ drop close-window ] }
        { [ dup pause-key? ] [ drop toggle-game-pause ] }
        { [ dup new-game-key? ] [ drop start-new-game ] }
        [
            [ snake-game>> ] dip over
            game-in-progress? [ ?handle-movement-key ] [ 2drop ] if
        ]
    } cond ;

: load-game-textures ( snake-gadget -- textures )
    dup textures>> [ ] [
        [
            snake-head-textures %%
            snake-body-textures %%
            snake-tail-textures %%
            food-texture %%
            background-texture %%
        ] H{ } make >>textures
        textures>>
    ] ?if ;

M: snake-gadget graft*
    [ [ do-updates ] curry 200 milliseconds every ] keep timer<< ;

M: snake-gadget ungraft*
    [ stop-timer f ] change-timer
    dup textures>> values [ dispose ] each
    f >>textures drop ;

M: snake-gadget pref-dim*
    drop snake-game-dim [ snake-game-cell-size * 20 + ] map ;

M: snake-gadget draw-gadget*
    [ load-game-textures game-textures ] keep [
        draw-background
        { 10 10 } [
            snake-game>>
            [ food-loc>> [ draw-food ] when* ]
            [
                [ snake-loc>> ]
                [ snake-dir>> opposite-dir ]
                [ snake>> ]
                tri draw-snake
            ] bi
        ] with-translation
    ] curry with-variable ;

M: snake-gadget handle-gesture
    swap dup key-down?
    [ sym>> handle-key ] [ 2drop ] if f ;
