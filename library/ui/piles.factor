! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl sequences vectors ;

! pile-align
!
! if the component is smaller than its allocated space, where to
! place the component inside the allocated space.
!
! pile-gap
! 
! amount of space, in pixels, between components.
! 
! pile-fill
! 
! if the component is smaller than its allocated space, how much
! to scale the size, where a value of 0 represents no scaling, and
! a value of 1 represents resizing to fully fill allocated space.
TUPLE: pile align gap fill ;

C: pile ( align gap fill -- pile )
    #! align: 0 left aligns, 1/2 center, 1 right.
    #! gap: between each child.
    #! fill: 0 leaves default width, 1 fills to pile width.
    [ <empty-gadget> swap set-delegate ] keep
    [ set-pile-fill ] keep
    [ set-pile-gap ] keep
    [ set-pile-align ] keep ;

: <line-pile> 0 { 0 0 0 } 1 <pile> ;

M: pile pref-dim ( pile -- dim )
    dup pile-gap { 0 1 0 } packed-pref-dim ;

: w- swap shape-w swap pref-size drop - ;
: pile-x/y ( pile gadget offset -- )
    rot pile-align * >fixnum y get rot move-gadget ;
: pile-w/h ( pile gadget offset -- )
    rot dup pile-gap first y [ + ] change
    pile-fill * >fixnum over pref-size dup y [ + ] change
    >r + r> rot resize-gadget ;
: vertically ( pile gadget -- ) 2dup w- 3dup pile-x/y pile-w/h ;

M: pile layout* ( pile -- )
    [
        dup gadget-children [ vertically ] each-with
    ] with-layout ;
