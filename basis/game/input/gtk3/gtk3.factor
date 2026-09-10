! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.mixin game.input game.input.gtk namespaces ;
IN: game.input.gtk3

SINGLETON: gtk3-game-input-backend
INSTANCE: gtk3-game-input-backend gtk-game-input-backend

gtk3-game-input-backend game-input-backend set-global
