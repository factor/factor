! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl sequences vectors ;

! A shelf is a box that lays out its contents horizontally.
TUPLE: shelf gap align fill ;

C: shelf ( align gap fill -- shelf )
    #! align: 0 left aligns, 1/2 center, 1 right.
    #! gap: between each child.
    #! fill: 0 leaves default width, 1 fills to pile width.
    <empty-gadget> over set-delegate
    [ set-shelf-fill ] keep
    [ set-shelf-gap ] keep
    [ set-shelf-align ] keep ;

: <default-shelf> 1/2 { 3 3 3 } 0 <shelf> ;
: <line-shelf> 0 0 1 <shelf> ;

M: shelf pref-dim ( pile -- dim )
    [
        dup shelf-gap swap gadget-children
        [ length 1 - 0 max * width set ] keep
        [
            pref-size
            height [ max ] change
            width [ + ] change
        ] each
    ] with-pref-size 0 3vector ;

: h- swap shape-h swap pref-size nip - ;
: shelf-x/y rot shelf-align * >fixnum >r x get r> rot move-gadget ;
: shelf-w/h ( shelf gadget offset -- )
    rot dup shelf-gap x [ + ] change
    shelf-fill * >fixnum >r dup pref-size over x [ + ] change
    r> + rot resize-gadget ; 
: horizontally ( shelf gadget -- )
    2dup h- 3dup shelf-x/y shelf-w/h ;

M: shelf layout* ( pile -- )
    [
        dup gadget-children [ horizontally ] each-with
    ] with-layout ;
