! Copyright (C) 2006 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.

REQUIRES: libs/lazy-lists ;

PROVIDE: apps/tetris
{ +files+ {
    "tetris-colours.factor"
    "tetromino.factor"
    "tetris-piece.factor"
    "tetris-board.factor"
    "tetris.factor"
    "tetris-gl.factor"
    "tetris-gadget.factor"
} }
{ +tests+ {
    "test/tetris-piece.factor"
    "test/tetris-board.factor"
    "test/tetris.factor"
} } ;

USE: tetris-gadget

MAIN: apps/tetris tetris-window ;
