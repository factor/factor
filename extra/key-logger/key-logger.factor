! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors bit-arrays calendar endian game.input io
io.encodings.binary io.files kernel literals math namespaces
threads timers ;
IN: key-logger

CONSTANT: frequency $[ 1/30 seconds ]

CONSTANT: path "resource:key-log.txt"

: update-key-caps-state ( -- )
    read-keyboard keys>>
    path binary [
        [ now unix-1970 time- duration>nanoseconds >integer ]
        [ bit-array>integer ] bi*
        [ 8 >be write ] bi@ flush
    ] with-file-appender ;

SYMBOL: key-logger

: start-key-logger ( -- )
    key-logger get-global [
        [
            open-game-input
            [ update-key-caps-state ] frequency every key-logger set-global
        ] in-thread
    ] unless ;

: stop-key-logger ( -- )
    key-logger get-global [ stop-timer ] when*
    f key-logger set-global
    close-game-input ;

MAIN: start-key-logger
