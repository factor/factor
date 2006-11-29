! Copyright (C) 2006 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic sequences math tetris-board tetris-piece tetromino errors lazy-lists ;
IN: tetris

TUPLE: tetris pieces last-update update-interval rows score game-state paused? running? ;

: default-width 10 ; inline
: default-height 20 ; inline

C: tetris ( width height -- tetris )
    >r <board> r> [ set-delegate ] keep
    dup board-width <piece-llist> over set-tetris-pieces
    0 over set-tetris-last-update
    0 over set-tetris-rows
    0 over set-tetris-score
    f over set-tetris-paused?
    t over set-tetris-running? ;

: <default-tetris> ( -- tetris ) default-width default-height <tetris> ;

: <new-tetris> ( old -- new )
    [ board-width ] keep board-height <tetris> ;

: tetris-board ( tetris -- board ) delegate ;

: tetris-current-piece ( tetris -- piece ) tetris-pieces car ;

: tetris-next-piece ( tetris -- piece ) tetris-pieces cdr car ;

: toggle-pause ( tetris -- )
    dup tetris-paused? not swap set-tetris-paused? ;

: tetris-level ( tetris -- level )
    tetris-rows 1+ 10 / ceiling ;

: tetris-update-interval ( tetris -- interval )
    tetris-level 1- 60 * 1000 swap - ;

: add-block ( tetris block -- )
    over tetris-current-piece tetromino-colour board-set-block ;

: game-over? ( tetris -- ? )
    dup dup tetris-next-piece piece-valid? ;

: new-current-piece ( tetris -- )
    game-over? [
        dup tetris-pieces cdr swap set-tetris-pieces
    ] [
        f swap set-tetris-running?
    ] if ;

: rows-score ( level n -- score )
    {
	{ [ dup 0 = ] [ drop 0 ]    }
	{ [ dup 1 = ] [ drop 40 ]   }
	{ [ dup 2 = ] [ drop 100 ]  }
	{ [ dup 3 = ] [ drop 300 ]  }
	{ [ dup 4 = ] [ drop 1200 ] }
	{ [ t ] [ "how did you clear that many rows?" throw ] }
    } cond swap 1+ * ;

: add-score ( tetris score -- )
    over tetris-score + swap set-tetris-score ;

: score-rows ( tetris n -- )
    2dup >r dup tetris-level r> rows-score add-score
    over tetris-rows + swap set-tetris-rows ;

: lock-piece ( tetris -- )
    [ dup tetris-current-piece piece-blocks [ add-block ] each-with ] keep
    dup new-current-piece dup check-rows score-rows ;

: can-rotate? ( tetris -- ? )
    dup tetris-current-piece clone dup 1 rotate-piece piece-valid? ;

: (rotate) ( inc tetris -- )
    dup can-rotate? [ tetris-current-piece swap rotate-piece ] [ 2drop ] if ;

: rotate ( tetris -- ) 1 swap (rotate) ;

: can-move? ( tetris move -- ? )
    >r dup tetris-current-piece clone dup r> move-piece piece-valid? ;

: tetris-move ( tetris move -- ? )
    #! moves the piece if possible, returns whether the piece was moved
    2dup can-move? [
	>r tetris-current-piece r> move-piece t
    ] [
	2drop f
    ] if ;

: move-left ( tetris -- ) { -1 0 } tetris-move drop ;

: move-right ( tetris -- ) { 1 0 } tetris-move drop ;

: move-down ( tetris -- )
    dup { 0 1 } tetris-move [ drop ] [ lock-piece ] if ;

: move-drop ( tetris -- )
    dup { 0 1 } tetris-move [ move-drop ] [ lock-piece ] if ;

: can-move? ( tetris move -- ? )
    >r dup tetris-current-piece clone dup r> move-piece piece-valid? ;

: update ( tetris -- )
    millis over tetris-last-update -
    over tetris-update-interval > [
	dup move-down
	millis swap set-tetris-last-update
    ] [ drop ] if ;

: maybe-update ( tetris -- )
    dup tetris-paused? over tetris-running? not or [ drop ] [ update ] if ;
