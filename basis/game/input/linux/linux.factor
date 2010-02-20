! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel game.input namespaces classes bit-arrays vectors ;
IN: game.input.linux

SINGLETON: linux-game-input-backend

linux-game-input-backend game-input-backend set-global

M: linux-game-input-backend (open-game-input)
    ;

M: linux-game-input-backend (close-game-input)
    ;

M: linux-game-input-backend (reset-game-input)
    ;

M: linux-game-input-backend get-controllers
    { } ;

M: linux-game-input-backend product-string
    drop "" ;
     
M: linux-game-input-backend product-id
    drop f ;
     
M: linux-game-input-backend instance-id
    drop f ;
     
M: linux-game-input-backend read-controller
    drop controller-state new ;
     
M: linux-game-input-backend calibrate-controller
    drop ;
     
M: linux-game-input-backend vibrate-controller
    3drop ;
     
M: linux-game-input-backend read-keyboard
    256 <bit-array> keyboard-state boa ;
     
M: linux-game-input-backend read-mouse
    0 0 0 0 2 <vector> mouse-state boa ;
     
M: linux-game-input-backend reset-mouse
    ;
