! Copyright (C) 2015 Sankaranarayanan Viswanathan
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar combinators destructors
formatting hash-sets images.loader kernel locals make math
namespaces opengl opengl.textures random sequences sets sorting
snake-game.helper timers ui ui.gadgets ui.gadgets.status-bar
ui.gadgets.worlds ui.gestures ui.render vocabs.loader ;

IN: snake-game

SYMBOLS: :left :right :up :down ;

SYMBOLS: :head :body :tail ;

SYMBOL: game-textures

CONSTANT: snake-game-dim { 12 10 }

TUPLE: snake-game
    snake snake-loc snake-dir food-loc
    { next-turn-dir initial: f }
    { score integer initial: 0 }
    { paused? boolean initial: t }
    { game-over? boolean initial: f } ;

TUPLE: snake-part
    dir type ;

: <snake-part> ( dir type -- snake-part )
    snake-part boa ;

: <snake> ( -- snake )
    [
        :left :head <snake-part> ,
        :left :body <snake-part> ,
        :left :tail <snake-part> ,
    ] V{ } make ;

: <snake-game> ( -- snake-game )
    snake-game new
    <snake> >>snake
    { 5 4 } clone >>snake-loc
    :right >>snake-dir
    { 1 1 } clone >>food-loc ;

TUPLE: snake-gadget < gadget
    snake-game timer textures ;

: start-new-game ( snake-gadget -- )
    <snake-game> >>snake-game drop ;

: <snake-gadget> ( -- snake-gadget )
    snake-gadget new
    [ start-new-game ] keep ;

: opposite-dir ( dir -- dir )
    H{
        { :left  :right }
        { :right :left }
        { :up    :down }
        { :down  :up }
    } at ;

: lookup-texture ( key -- texture )
    game-textures get at ;

: screen-loc ( loc -- loc )
    [ 20 * ] map ;

: draw-sprite* ( key screen-loc -- )
    [ lookup-texture draw-texture ] with-translation ;

: draw-sprite ( grid-loc key -- )
    swap screen-loc draw-sprite* ;

: draw-food ( loc -- )
    "food" draw-sprite ;

: draw-background ( -- )
    { 0 0 } "background" draw-sprite ;

: offset ( loc dim -- loc )
    [ + ] 2map ;

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
    2array [ name>> rest ] map "body" prefix "-" join
    draw-sprite ;

: draw-snake-tail ( loc facing-dir -- )
    name>> rest "tail-" prepend draw-sprite ;

: draw-snake-part ( loc from-dir snake-part -- )
    dup type>> {
        { :head [ drop opposite-dir draw-snake-head ] }
        { :tail [ drop draw-snake-tail ] }
        { :body [ dir>> draw-snake-body ] }
    } case ;

: ?roll-over ( x max -- x )
    {
        { [ 2dup >= ] [ 2drop 0 ] }
        { [ over neg? ] [ nip 1 - ] }
        [ drop ]
    } cond ;

: ?roll-over-x ( x -- x )
    snake-game-dim first ?roll-over ;

: ?roll-over-y ( y -- y )
    snake-game-dim second ?roll-over ;

: move ( loc dim -- loc )
    offset first2
    [ ?roll-over-x ] [ ?roll-over-y ] bi* 2array ;

: relative-loc ( loc dir -- loc )
    {
        { :left  [ { -1  0 } move ] }
        { :right [ {  1  0 } move ] }
        { :up    [ {  0 -1 } move ] }
        { :down  [ {  0  1 } move ] }
    } case ;

: draw-snake-reduce-step ( loc from-dir snake-part -- {new-loc,new-from-dir} )
    nip dir>> [ relative-loc ] keep 2array ;

: draw-snake ( snake loc from-dir -- )
    2array 2dup
    [
        [ first2 ] dip
        [ draw-snake-part ] [ draw-snake-reduce-step ] 3bi
    ] reduce drop
    ! make sure to draw the head again
    swap first [ first2 ] dip draw-snake-part ;

: grow-snake ( snake dir -- snake )
    opposite-dir :head <snake-part> prefix
    dup second :body >>type drop ;

: snake-shape ( snake -- dirs )
    [ dir>> ] map ;

: move-snake ( snake dir -- snake )
    dupd [ snake-shape but-last ] dip
    opposite-dir prefix [ >>dir ] 2map ;

: update-snake-shape ( snake-game dir growing? -- )
    [ [ grow-snake ] curry change-snake ]
    [ [ move-snake ] curry change-snake ]
    if drop ;

: update-snake-loc ( snake-game dir -- )
    [ relative-loc ] curry change-snake-loc drop ;

: update-snake-dir ( snake-game dir -- )
    >>snake-dir drop ;

: point>index ( loc -- n )
    first2 [ ] [ snake-game-dim first * ] bi* + ;

: index>point ( n -- loc )
    snake-game-dim first /mod swap 2array ;

: snake-occupied-locs ( snake head-loc -- points )
    [ dir>> relative-loc ] accumulate nip ;

: snake-occupied-indices ( snake head-loc -- points )
    snake-occupied-locs [ point>index ] map natural-sort ;

: all-indices ( -- points )
    snake-game-dim first2 * iota ;

: snake-unoccupied-indices ( snake head-loc -- points )
    [ all-indices ] 2dip snake-occupied-indices >hash-set without ;

: snake-will-eat-itself? ( snake-game dir -- ? )
    [ [ snake>> ] [ snake-loc>> ] bi ] dip relative-loc
    [ snake-occupied-locs rest ] keep
    swap member? ;

: snake-will-eat-food? ( snake-game dir -- ? )
    [ [ food-loc>> ] [ snake-loc>> ] bi ] dip
    relative-loc = ;

: random-sample ( seq -- e )
    1 sample first ;

: generate-food ( snake-game -- )
    [
        [ snake>> ] [ snake-loc>> ] bi
        snake-unoccupied-indices random-sample index>point
    ] keep food-loc<< ;

: update-score ( snake-game -- )
    [ 1 + ] change-score
    drop ;

: update-snake ( snake-game dir -- )
    2dup snake-will-eat-food?
    {
        [ [ drop update-score ] [ 2drop ] if ]
        [ update-snake-shape ]
        [ drop update-snake-loc ]
        [ drop update-snake-dir ]
        [ nip [ generate-food ] [ drop ] if ]
    } 3cleave ;

: game-over ( snake-game -- )
    t >>game-over? drop ;

: game-in-progress? ( snake-game -- ? )
    [ game-over?>> ] [ paused?>> ] bi or not ;

: ?handle-pending-turn ( snake-game -- )
    dup next-turn-dir>> [
        >>snake-dir
        f >>next-turn-dir
    ] when* drop ;

: do-game-step ( gadget -- )
    dup game-in-progress? [
        dup ?handle-pending-turn
        dup snake-dir>>
        2dup snake-will-eat-itself?
        [ drop game-over ] [ update-snake ] if
    ] [ drop ] if ;

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
        
M: snake-gadget pref-dim*
    drop snake-game-dim [ 20 * 20 + ] map ;

: load-sprite-image ( filename -- image )
    [ snake-game vocabulary>> vocab-dir ] dip
    "vocab:%s/%s" sprintf load-image ;

: make-texture ( image -- texture )
    { 0 0 } <texture> ;

: make-sprites ( filename cols rows -- seq )
    [ load-sprite-image ] 2dip generate-sprite-sheet
    [ make-texture ] map ;

: snake-head-textures ( -- assoc )
    "head.png" 1 4 make-sprites
    { "head-up" "head-right" "head-down" "head-left" }
    [ swap 2array ] 2map ;

:: assoc-with-value-like ( assoc key seq -- )
    key assoc at :> value
    seq [ [ value ] dip assoc set-at ] each ;

: snake-body-textures ( -- assoc )
    "body.png" 3 2 make-sprites
    { 1 2 3 4 5 6 }
    [ swap 2array ] 2map
    dup 1 { "body-right-up" "body-down-left" } assoc-with-value-like
    dup 2 { "body-down-right" "body-left-up" } assoc-with-value-like
    dup 3 { "body-right-right" "body-left-left" } assoc-with-value-like
    dup 4 { "body-up-up" "body-down-down" } assoc-with-value-like    
    dup 5 { "body-up-right" "body-left-down" } assoc-with-value-like
    dup 6 { "body-right-down" "body-up-left" } assoc-with-value-like
    dup [ { 1 2 3 4 5 6 } ] dip [ delete-at ] curry each ;

: snake-tail-textures ( -- assoc )
    "tail.png" 2 2 make-sprites
    { "tail-down" "tail-left" "tail-up" "tail-right" }
    [ swap 2array ] 2map ;

: food-texture ( -- assoc )
    "food" "food.png" load-sprite-image make-texture
    2array 1array ;

: background-texture ( -- assoc )
    "background" "background.png" load-sprite-image make-texture
    2array 1array ;

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

M: snake-gadget draw-gadget*
    [ load-game-textures game-textures ] keep [
        draw-background
        { 10 10 } [
            snake-game>>
            [ food-loc>> [ draw-food ] when* ]
            [
                [ snake>> ]
                [ snake-loc>> ]
                [ snake-dir>> opposite-dir ]
                tri draw-snake
            ] bi
        ] with-translation
    ] curry with-variable ;

M: snake-gadget graft*
    [ [ do-updates ] curry 200 milliseconds every ] keep timer<< ;

M: snake-gadget ungraft*
    [ stop-timer f ] change-timer
    dup textures>> values [ dispose ] each
    f >>textures drop ;

: key-action ( key -- action )
    H{
        { "RIGHT"  :right }
        { "LEFT"   :left }
        { "UP"     :up }
        { "DOWN"   :down }
    } at ;

: quit-key? ( key -- ? )
    HS{ "ESC" "q" "Q" } in? ;

: pause-key? ( key -- ? )
    HS{ " " "SPACE" "p" "P" } in? ;

: new-game-key? ( key -- ? )
    HS{ "ENTER" "RET" "n" "N" } in? ;

: ?handle-movement-key ( snake-game key -- )
    key-action
    [
        2dup [ snake-dir>> opposite-dir ] dip =
        [ 2drop ] [ >>next-turn-dir drop ] if
    ] [ drop ] if* ;

: toggle-game-pause ( snake-gadget -- )
    snake-game>> [ not ] change-paused? drop ;

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

M: snake-gadget handle-gesture
    swap dup key-down?
    [ sym>> handle-key ] [ 2drop ] if f ;

: <snake-world-attributes> ( -- world-attributes )
    <world-attributes> "Snake Game" >>title    
    [
        { maximize-button resize-handles } without
    ] change-window-controls ;

: play-snake-game ( -- )
    [ <snake-gadget> <snake-world-attributes> open-status-window ] with-ui ;

MAIN: play-snake-game
