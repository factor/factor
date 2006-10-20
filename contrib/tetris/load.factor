! Copyright (C) 2006 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.

REQUIRES: contrib/lazy-lists ;

PROVIDE: contrib/tetris {
    "tetris-colours.factor" "tetromino.factor" "tetris-piece.factor"
    "tetris-board.factor" "tetris.factor" "tetris-gl.factor"
    "tetris-gadget.factor"
} {
    "test/tetris-piece.factor" "test/tetris-board.factor" "test/tetris.factor"
} ;

USE: tetris-gadget

MAIN: contrib/tetris tetris-window ;
