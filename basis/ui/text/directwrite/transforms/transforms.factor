! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data arrays continuations kernel locals
math namespaces opengl opengl.gl sequences specialized-arrays ;
SPECIALIZED-ARRAY: double
IN: ui.text.directwrite.transforms

! Keep translations in doubles until a visible tile has been rebased.
! Driver modelview matrices can lose whole pixels on very long lines.
SYMBOL: directwrite-transform

: native-directwrite-transform ( -- matrix )
    16 double <c-array> [ GL_MODELVIEW_MATRIX swap glGetDoublev ] keep >array ;

: current-directwrite-transform ( -- matrix )
    directwrite-transform get [ native-directwrite-transform ] unless* ;

:: multiply-directwrite-transforms ( a b -- matrix )
    16 <iota> [| i |
        i 4 mod :> row
        i 4 /i :> col
        0.0 4 <iota> [| k |
            k 4 * row + a nth col 4 * k + b nth * +
        ] each
    ] map ;

:: translate-directwrite-transform ( matrix point -- translated )
    point first2 :> ( x y )
    matrix >array :> translated
    4 <iota> [| row |
        row matrix nth x * row 4 + matrix nth y * +
        row 12 + matrix nth + row 12 + translated set-nth
    ] each translated ;

:: directwrite-translate ( point -- )
    directwrite-transform get [
        point translate-directwrite-transform directwrite-transform set
    ] when*
    point gl-translate-legacy ;

:: directwrite-scale ( sx sy -- )
    directwrite-transform get [ >array :> matrix
        4 <iota> [| row |
            row matrix [ sx * ] change-nth
            row 4 + matrix [ sy * ] change-nth
        ] each
        matrix directwrite-transform set
    ] when*
    sx sy gl-scale-2d-legacy ;

:: with-directwrite-matrix ( quot -- )
    current-directwrite-transform directwrite-transform [
        glPushMatrix [ quot call( -- ) ] [ glPopMatrix ] finally
    ] with-variable ;

:: with-directwrite-translation ( point quot -- )
    [ point directwrite-translate quot call( -- ) ] with-directwrite-matrix ;

: install-directwrite-transforms ( -- )
    gl3-mode? get-global [
        [ directwrite-translate ] gl-translate-hook set-global
        [ directwrite-scale ] gl-scale-2d-hook set-global
        [ with-directwrite-matrix ] with-matrix-hook set-global
        [ with-directwrite-translation ] with-translation-hook set-global
    ] unless ;
