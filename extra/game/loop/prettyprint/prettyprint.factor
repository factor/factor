! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors debugger game.loop io ;
IN: game.loop.prettyprint

M: game-loop-error-state error.
    "An error occurred inside a game loop." print
    "The game loop has been stopped to prevent runaway errors." print
    "The error was:" print nl
    error>> error. ;
