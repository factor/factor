! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl ;

: layout ( gadget -- )
    #! Set the gadget's width and height to its preferred width
    #! and height. The gadget's children are laid out first.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        dup gadget-paint [
            f over set-gadget-relayout?
            dup layout*
            gadget-children [ layout ] each
        ] bind
    ] [
        drop
    ] ifte ;

: with-pref-size ( quot -- )
    [
        0 width set  0 height set  call  width get height get
    ] with-scope ; inline

: with-layout ( quot -- )
    [ 0 x set 0 y set call ] with-scope ; inline

: default-gap 3 ;

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

! A shelf is a box that lays out its contents horizontally.
TUPLE: shelf gap align fill ;

C: shelf ( align gap fill -- shelf )
    <empty-gadget> over set-delegate
    [ set-shelf-fill ] keep
    [ set-shelf-gap ] keep
    [ set-shelf-align ] keep ;

: <default-shelf> 1/2 default-gap 0 <shelf> ;
: <line-shelf> 0 0 1 <shelf> ;

M: shelf pref-size ( pile -- w h )
    [
        dup shelf-gap swap gadget-children
        [ length 1 - 0 max * width set ] keep
        [
            pref-size
            height [ max ] change
            width [ + ] change
        ] each
    ] with-pref-size ;

: h- swap shape-h swap pref-size nip - ;
: shelf-x/y rot shelf-align * >fixnum >r x get r> rot move-gadget ;
: shelf-w/h ( pile gadget offset -- )
    rot dup shelf-gap x [ + ] change
    shelf-fill * >fixnum >r dup pref-size over x [ + ] change
    r> drop rot resize-gadget ; 
: horizontally ( pile gadget -- )
    2dup h- 3dup shelf-x/y shelf-w/h ;

M: shelf layout* ( pile -- )
    [
        dup gadget-children [ horizontally ] each-with
    ] with-layout ;

! A border lays out its children on top of each other, all with
! a 5-pixel padding.
TUPLE: border size ;

C: border ( child delegate size -- border )
    [ set-border-size ] keep
    [ set-delegate ] keep
    [ over [ add-gadget ] [ 2drop ] ifte ] keep ;

: empty-border ( child -- border )
    <empty-gadget> 5 <border> ;

: line-border ( child -- border )
    0 0 0 0 <etched-rect> <gadget> 5 <border> ;

: filled-border ( child -- border )
    0 0 0 0 <plain-rect> <gadget> 5 <border> ;

: gadget-child gadget-children car ;

: layout-border-x/y ( border -- )
    dup border-size dup rot gadget-child move-gadget ;

: layout-border-w/h ( border -- )
    [ border-size 2 * ] keep
    [ shape-w over - ] keep
    [ shape-h rot - ] keep
    gadget-child resize-gadget ;

M: border pref-size ( border -- w h )
    [ border-size 2 * ] keep
    gadget-child pref-size >r over + r> rot + ;

M: border layout* ( border -- )
    dup layout-border-x/y layout-border-w/h ;

! A stack just lays out all its children on top of each other.
TUPLE: stack ;
C: stack ( list -- stack )
    <empty-gadget> over set-delegate
    swap [ over add-gadget ] each ;

: max-size ( stack -- w h )
    [
        [
            dup
            shape-w width [ max ] change
            shape-h height [ max ] change
        ] each
    ] with-pref-size ;

M: stack pref-size gadget-children max-size ;

M: stack layout* ( stack -- )
    dup gadget-children [
        >r dup shape-w over shape-h r> resize-gadget
    ] each drop ;
