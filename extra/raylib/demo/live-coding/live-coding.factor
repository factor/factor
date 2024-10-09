! Copyright (C) 2024 Dmitry Matveyev.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel namespaces raylib raylib.live-coding math.parser
accessors ;
IN: raylib.demo.live-coding

SYMBOL: counter
SYMBOL: text-color
TUPLE: my-color color ;

: color ( -- color )
    text-color get color>> ;

: game-loop ( -- )
    counter inc

    counter get 100 = [ "something went wrong" throw ] when

    KEY_F5 on-key-reload-code

    begin-drawing
        RAYWHITE clear-background
        counter get number>string 10 10 64 color draw-text
    end-drawing ;

: main ( -- )
    800 640 "Raylib Live Coding Demo" init-window
    60 set-target-fps
    0 counter set
    BLACK my-color boa text-color set
    [ game-loop ] until-window-should-close-with-live-coding
    close-window ;

: dev ( -- )
    [ main ] with-live-coding ;

MAIN: main
