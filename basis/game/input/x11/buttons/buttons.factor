! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.bitwise sequences ;
IN: game.input.x11.buttons

: button-mask>buttons ( mask -- buttons )
    { 8 9 10 11 12 } [ bit? ] with map ;
