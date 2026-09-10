! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.mixin game.input game.input.gtk namespaces ;
IN: game.input.gtk4

SINGLETON: gtk4-game-input-backend
INSTANCE: gtk4-game-input-backend gtk-game-input-backend

gtk4-game-input-backend game-input-backend set-global
