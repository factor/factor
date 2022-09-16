! Copyright (C) 2015-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors colors kernel locals math math.constants
math.functions opengl.gl sequences ui.gadgets system
ui.render ui.tools.environment.theme ;
IN: ui.tools.environment.navigation.dot-pattern

TUPLE: dot-pattern < gadget ;

: <dot-pattern> ( child -- gadget )
    dot-pattern new swap add-gadget ;

CONSTANT: dr 8

:: draw-dot-ring ( x y n -- )
    n 6 * <iota> [
        tau * 6 n * /
        [ sin n * dr * x 2 /i + dup [ 3 > ] [ x 3 - < ] bi and ]
        [ cos n * dr * 44 + dup [ 3 > ] [ y 3 - < ] bi and ] bi
        swapd and [ glVertex2f ] [ drop drop ] if
    ] each ;

M: dot-pattern draw-gadget*
    os windows? [ drop ] [
        dim>> [ first2 ] [ first 2 / dr /i ] bi
        GL_POINT_SMOOTH glEnable
        9 glPointSize
        GL_POINTS glBegin
        blue-background second >rgba-components drop 0.12 glColor4f
        <iota> [ draw-dot-ring ] 2with each
        glEnd 
    ] if ;

M: dot-pattern pref-dim*
    drop { 0 65 } ;

M: dot-pattern layout*
    [ dim>> first ] [ gadget-child ] bi dup pref-dim second
    swapd 2array >>dim { 0 23 } >>loc drop ;
