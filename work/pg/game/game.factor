USING: accessors combinators kernel lists math math.functions sequences system pg.board pg.piece pg.tetromino logging ;
IN: pg.game

TUPLE: pg
    { board board }
    { pieces }
    { last-update integer initial: 0 }
    { rows integer initial: 0 }
    { score integer initial: 0 }
    { paused? initial: f }
    { running? initial: t } ;

CONSTANT: default-width 10
CONSTANT: default-height 20

: <pg> ( width height -- pg )
    dupd <board> swap <piece-llist>
    pg new swap >>pieces swap >>board ;

: <default-pg> ( -- pg ) default-width default-height <pg> ;

: <new-pg> ( old -- new )
    board>> [ width>> ] [ height>> ] bi <pg> ;

: current-piece ( pg -- piece ) pieces>> car ;

: next-piece ( pg -- piece ) pieces>> cdr car ;

: toggle-pause ( pg -- )
    [ not ] change-paused? drop ;

: level>> ( pg -- level )
    rows>> 1 + 10 / ceiling ;

: update-interval ( pg -- interval )
    level>> 1 - 60 * 1,000,000,000 swap - ;

: add-block ( pg block -- )
    over [ board>> ] 2dip current-piece tetromino>> colour>> set-block ;

: game-over? ( pg -- ? )
    [ board>> ] [ next-piece ] bi piece-valid? not ;

: new-current-piece ( pg -- pg )
    dup game-over? [
        f >>running?
    ] [
        [ cdr ] change-pieces
    ] if ;

: rows-score ( level n -- score )
    {
        { 0 [ 0 ] }
        { 1 [ 40 ] }
        { 2 [ 100 ] }
        { 3 [ 300 ] }
        { 4 [ 1200 ] }
    } case swap 1 + * ;

: add-score ( pg n-rows -- pg )
    over level>> swap rows-score swap [ + ] change-score ;

: add-rows ( pg rows -- pg )
    swap [ + ] change-rows ;

: score-rows ( pg n -- )
    [ add-score ] keep add-rows drop ;

: lock-piece ( pg -- )
    [ dup current-piece piece-blocks [ add-block ] with each ] keep
    new-current-piece dup board>> check-rows score-rows ;

: can-rotate? ( pg -- ? )
    [ board>> ] [ current-piece clone 1 rotate-piece ] bi piece-valid? ;

: (rotate) ( inc pg -- )
    dup can-rotate? [ current-piece swap rotate-piece drop ] [ 2drop ] if ;

: rotate-left ( pg -- ) -1 swap (rotate) ;

: rotate-right ( pg -- ) 1 swap (rotate) ;

: can-move? ( pg move -- ? )
    [ drop board>> ] [ [ current-piece clone ] dip move-piece ] 2bi piece-valid? ;

: pg-move ( pg move -- ? )
    ! moves the piece if possible, returns whether the piece was moved
    2dup can-move? [
        [ current-piece ] dip move-piece drop t
    ] [
        2drop f
    ] if ;

: move-left ( pg -- ) { -1 0 } pg-move drop ;

: move-right ( pg -- ) { 1 0 } pg-move drop ;

: move-down ( pg -- )
    dup { 0 1 } pg-move [ drop ] [ lock-piece ] if ;

: move-drop ( pg -- )
    dup { 0 1 } pg-move [ move-drop ] [ lock-piece ] if ;

: update ( pg -- )
    nano-count over last-update>> -
    over update-interval > [
        nano-count >>last-update
    ] when drop ;

: ?update ( pg -- )
    dup [ paused?>> ] [ running?>> not ] bi or [ drop ] [ update ] if ;
