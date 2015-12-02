! Copyright (C) 2015 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators kernel make math random
sequences sets snake-game.constants snake-game.util sorting ;

IN: snake-game.game

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

: game-loc>index ( loc -- n )
    first2 snake-game-dim first * + ;

: index>game-loc ( n -- loc )
    snake-game-dim first /mod swap 2array ;

: snake-shape ( snake -- dirs )
    [ dir>> ] map ;

: grow-snake ( snake dir -- snake )
    opposite-dir :head <snake-part> prefix
    dup second :body >>type drop ;

: move-snake ( snake dir -- snake )
    dupd [ snake-shape but-last ] dip
    opposite-dir prefix [ >>dir ] 2map ;

: all-indices ( -- points )
    snake-game-dim first2 * iota ;

: snake-occupied-locs ( snake head-loc -- points )
    [ dir>> relative-loc ] accumulate nip ;

: snake-occupied-indices ( snake head-loc -- points )
    snake-occupied-locs [ game-loc>index ] map natural-sort ;

: snake-unoccupied-indices ( snake head-loc -- points )
    [ all-indices ] 2dip snake-occupied-indices without ;

: snake-will-eat-food? ( snake-game dir -- ? )
    [ [ food-loc>> ] [ snake-loc>> ] bi ] dip
    relative-loc = ;

: update-score ( snake-game -- )
    [ 1 + ] change-score
    drop ;

: update-snake-shape ( snake-game dir growing? -- )
    [ [ grow-snake ] curry change-snake ]
    [ [ move-snake ] curry change-snake ]
    if drop ;

: update-snake-loc ( snake-game dir -- )
    [ relative-loc ] curry change-snake-loc drop ;

: update-snake-dir ( snake-game dir -- )
    >>snake-dir drop ;

: generate-food ( snake-game -- )
    [
        [ snake>> ] [ snake-loc>> ] bi
        snake-unoccupied-indices random index>game-loc
    ] keep food-loc<< ;

: game-in-progress? ( snake-game -- ? )
    [ game-over?>> ] [ paused?>> ] bi or not ;

: ?handle-pending-turn ( snake-game -- )
    dup next-turn-dir>> [
        >>snake-dir
        f >>next-turn-dir
    ] when* drop ;

: snake-will-eat-itself? ( snake-game dir -- ? )
    [ [ snake>> ] [ snake-loc>> ] bi ] dip relative-loc
    [ snake-occupied-locs rest ] keep
    swap member? ;

: game-over ( snake-game -- )
    t >>game-over? drop ;

: update-snake ( snake-game dir -- )
    2dup snake-will-eat-food?
    {
        [ [ drop update-score ] [ 2drop ] if ]
        [ update-snake-shape ]
        [ drop update-snake-loc ]
        [ drop update-snake-dir ]
        [ nip [ generate-food ] [ drop ] if ]
    } 3cleave ;

: do-game-step ( snake-game -- )
    dup game-in-progress? [
        dup ?handle-pending-turn
        dup snake-dir>>
        2dup snake-will-eat-itself?
        [ drop game-over ] [ update-snake ] if
    ] [ drop ] if ;
