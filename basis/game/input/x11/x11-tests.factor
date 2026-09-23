! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: game.input game.input.x11 kernel namespaces tools.test x11 ;
IN: game.input.x11.tests

: without-x-display ( quot -- )
    H{ { game-input-backend x11-game-input-backend } { dpy f } }
    swap with-variables ; inline

: no-x-display? ( error -- ? )
    "Cannot connect to X server - check $DISPLAY" = ;

[ [ open-game-input ] without-x-display ] [ no-x-display? ] must-fail-with
{ f } [ game-input-opened? ] unit-test

[ [ read-keyboard ] without-x-display ] [ no-x-display? ] must-fail-with
[ [ read-mouse ] without-x-display ] [ no-x-display? ] must-fail-with
