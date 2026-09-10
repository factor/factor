! Copyright (C) 2010 Erik Charlebois, William Schlieper.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.mixin destructors game.input
io.encodings.binary io.files kernel linux.input-events
linux.input-events.ffi math sequences unix.ffi ;
IN: game.input.linux

MIXIN: linux-game-input-backend

TUPLE: linux-controller < controller path meta state thread fd buttons quit? ;
: <linux-controller> ( path -- controller )
    linux-controller new
        swap >>path
        dup path>> get-event-device-info >>meta
        dup meta>> "path" of binary <file-reader> handle>> fd>> >>fd
        H{ } clone >>state
        dup meta>> "capabilities" of EV_KEY of keys seq>explode-positions >>buttons ; inline
        ! tuck state>> '[ _ _ read-events ] in-thread ;

M: linux-controller dispose* fd>> close drop ;

TUPLE: linux-controller-state < controller-state abs ;

M: linux-game-input-backend get-controllers
    get-input-events-joysticks values [ <linux-controller> ] map ;

M: linux-game-input-backend product-string
    meta>> "name" of ;

M: linux-game-input-backend product-id
    meta>> "id" of ;

M: linux-game-input-backend instance-id
    drop f ;

M: linux-game-input-backend read-controller
    [ linux-controller-state new ] dip
    [ fd>> ] [ meta>> ] bi
    [ drop evdev-get-key seq>explode-positions [ <INPUT_KEY> ] zip-with >>buttons ]
    [ "capabilities" of EV_ABS of [ [ first first evdev-get-abs ] [ first ] bi swap 2array ] with map >>abs ] 2bi ;

M: linux-game-input-backend calibrate-controller
    drop ;

M: linux-game-input-backend vibrate-controller
    3drop ;
