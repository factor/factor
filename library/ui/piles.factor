! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl ;

! A pile is a box that lays out its contents vertically.
TUPLE: pile align gap fill ;

C: pile ( align gap fill -- pile )
    #! align: 0 left aligns, 1/2 center, 1 right.
    #! gap: between each child.
    #! fill: 0 leaves default width, 1 fills to pile width.
    [ <empty-gadget> swap set-delegate ] keep
    [ set-pile-fill ] keep
    [ set-pile-gap ] keep
    [ set-pile-align ] keep ;

: <default-pile> 1/2 default-gap 0 <pile> ;
: <line-pile> 0 0 1 <pile> ;

M: pile pref-size ( pile -- w h )
    [
        dup pile-gap swap gadget-children
        [ length 1 - 0 max * height set ] keep
        [
            pref-size
            height [ + ] change
            width [ max ] change
        ] each
    ] with-pref-size ;

: w- swap shape-w swap pref-size drop - ;
: pile-x/y ( pile gadget offset -- )
    rot pile-align * >fixnum y get rot move-gadget ;
: pile-w/h ( pile gadget offset -- )
    rot dup pile-gap y [ + ] change
    pile-fill * >fixnum over pref-size dup y [ + ] change
    >r + r> rot resize-gadget ;
: vertically ( pile gadget -- ) 2dup w- 3dup pile-x/y pile-w/h ;

M: pile layout* ( pile -- )
    [
        dup gadget-children [ vertically ] each-with
    ] with-layout ;
