! Copyright (C) 2015 Sankaranarayanan Viswanathan.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators kernel make math
math.vectors random sequences sets sorting ;

IN: snake-game.game

SYMBOLS: :left :right :up :down ;

SYMBOLS: :head :body :tail ;

CONSTANT: snake-game-dim { 12 10 }

TUPLE: snake-game
    snake snake-loc snake-dir food-loc
    { next-turn-dir initial: f }
    { score integer initial: 0 }
    { paused? boolean initial: t }
    { game-over? boolean initial: f } ;

TUPLE: snake-part
    dir type ;

C: <snake-part> snake-part

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

: ?roll-over ( x max -- x )
    {
        { [ 2dup >= ] [ 2drop 0 ] }
        { [ over neg? ] [ nip 1 - ] }
        [ drop ]
    } cond ;

: move-loc ( loc dir -- loc )
    H{
        { :left  { -1  0 } }
        { :right {  1  0 } }
        { :up    {  0 -1 } }
        { :down  {  0  1 } }
    } at v+ snake-game-dim [ ?roll-over ] 2map ;

: opposite-dir ( dir -- dir )
    H{
        { :left  :right }
        { :right :left }
        { :up    :down }
        { :down  :up }
    } at ;

: game-loc>index ( loc -- n )
    first2 snake-game-dim first * + ;

: index>game-loc ( n -- loc )
    snake-game-dim first /mod swap 2array ;

: grow-snake ( snake dir -- snake )
    opposite-dir :head <snake-part> prefix
    dup second :body >>type drop ;

: move-snake ( snake dir -- snake )
    [ dup but-last [ dir>> ] map ] dip
    opposite-dir prefix [ >>dir ] 2map ;

: all-indices ( -- points )
    snake-game-dim product <iota> ;

: snake-occupied-locs ( snake head-loc -- points )
    [ dir>> move-loc ] accumulate nip ;

: snake-occupied-indices ( snake head-loc -- points )
    snake-occupied-locs [ game-loc>index ] map sort ;

: snake-unoccupied-indices ( snake head-loc -- points )
    [ all-indices ] 2dip snake-occupied-indices without ;

: snake-will-eat-food? ( snake-game -- ? )
    [ food-loc>> ] [ snake-loc>> ] [ snake-dir>> ] tri move-loc = ;

: increase-score ( snake-game -- snake-game )
    [ 1 + ] change-score ;

: update-snake-shape ( snake-game growing? -- snake-game )
    [ dup snake-dir>> ] dip
    '[ _ _ [ grow-snake ] [ move-snake ] if ] change-snake ;

: update-snake-loc ( snake-game -- snake-game )
    dup snake-dir>> '[ _ move-loc ] change-snake-loc ;

: generate-food ( snake-game -- snake-game )
    dup [ snake>> ] [ snake-loc>> ] bi
    snake-unoccupied-indices random index>game-loc
    >>food-loc ;

: game-in-progress? ( snake-game -- ? )
    [ game-over?>> ] [ paused?>> ] bi or not ;

: ?handle-pending-turn ( snake-game -- )
    dup next-turn-dir>> [
        >>snake-dir
        f >>next-turn-dir
    ] when* drop ;

: snake-will-eat-itself? ( snake-game -- ? )
    [ snake>> ] [ snake-loc>> ] [ snake-dir>> ] tri move-loc
    [ snake-occupied-locs rest ] keep swap member? ;

: game-over ( snake-game -- )
    t >>game-over? drop ;

: update-snake ( snake-game -- )
    dup snake-will-eat-food? {
        [ [ increase-score ] when ]
        [ update-snake-shape ]
        [ drop update-snake-loc ]
        [ [ generate-food ] when ]
    } cleave drop ;

: do-game-step ( snake-game -- )
    dup game-in-progress? [
        dup ?handle-pending-turn
        dup snake-will-eat-itself?
        [ game-over ] [ update-snake ] if
    ] [ drop ] if ;
