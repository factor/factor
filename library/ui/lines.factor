! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl ;

! A line.
TUPLE: line x y w h ;

M: line shape-x dup line-x dup rot line-w + min ;
M: line shape-y dup line-y dup rot line-h + min ;
M: line shape-w line-w abs 1 + ;
M: line shape-h line-h abs 1 + ;

: line-pos ( line -- #{ x y }# )
    dup line-x x get + swap line-y y get + rect> ;

: line-dir ( line -- #{ w h }# ) dup line-w swap line-h rect> ;

: move-line-x ( x line -- )
    [ line-w dupd - max ] keep set-line-x ;

: move-line-y ( y line -- )
    [ line-h dupd - max ] keep set-line-y ;

M: line move-shape ( x y line -- )
    tuck move-line-y move-line-x ;

: resize-line-w ( w line -- )
    >r 1 - r>
    dup line-w 0 >= [
        set-line-w
    ] [
        2dup
        [ [ line-w + ] keep line-x + ] keep set-line-x
        >r neg r> set-line-w
    ] ifte ;

: resize-line-h ( w line -- )
   >r 1 - r>
    dup line-h 0 >= [
        set-line-h
    ] [
        2dup
        [ [ line-h + ] keep line-y + ] keep set-line-y
        >r neg r> set-line-h
    ] ifte ;

M: line resize-shape ( w h line -- )
    tuck resize-line-h resize-line-w ;

: line>screen ( shape -- x1 y1 x2 y2 )
    [ line-x x get + ] keep
    [ line-y y get + ] keep
    [ line-w pick + ] keep
    line-h pick + ; 

: line-inside? ( p d -- ? )
    dupd proj - absq 4 < ;

M: line inside? ( point line -- ? )
    2dup inside-rect? [
        [ line-pos - ] keep line-dir line-inside?
    ] [
        2drop f
    ] ifte ;

M: line draw-shape ( line -- )
    >r surface get r>
    line>screen
    fg rgb
    aalineColor ;
