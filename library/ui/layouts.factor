! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces ;

GENERIC: layout* ( gadget -- )
M: gadget layout* drop ;

: layout ( gadget -- )
    #! Set the gadget's width and height to its preferred width
    #! and height. The gadget's children are laid out first.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        dup gadget-paint [
            f over set-gadget-relayout?
            dup gadget-children [ layout ] each
            layout*
        ] bind
    ] [
        drop
    ] ifte ;

: default-gap 3 ;

! A pile is a box that lays out its contents vertically.
TUPLE: pile align gap fill delegate ;

C: pile ( align gap fill -- pile )
    #! align: 0 left aligns, 1/2 center, 1 right.
    #! gap: between each child.
    #! fill: 0 leaves default width, 1 fills to pile width.
    [ <empty-gadget> swap set-pile-delegate ] keep
    [ set-pile-fill ] keep
    [ set-pile-gap ] keep
    [ set-pile-align ] keep ;

: <default-pile> 1/2 default-gap 0 <pile> ;
: <line-pile> 0 0 1 <pile> ;

: horizontal-layout ( gadget y box -- )
    pick shape-w over shape-w swap - swap pile-align * >fixnum
    swap rot move-gadget ;

M: pile layout* ( pile -- )
    dup pile-gap over gadget-children run-heights >r >r
    dup gadget-children max-width r> pick resize-gadget
    dup gadget-children r> zip [
        uncons rot horizontal-layout
    ] each-with ;

! A shelf is a box that lays out its contents horizontally.
TUPLE: shelf gap align delegate ;

C: shelf ( align gap -- shelf )
    <empty-gadget> over set-shelf-delegate
    [ set-shelf-gap ] keep
    [ set-shelf-align ] keep ;

: vertical-layout ( gadget x box -- )
    pick shape-h over shape-h swap - swap shelf-align * >fixnum
    rot move-gadget ;

: <default-shelf> 1/2 default-gap <shelf> ;
: <line-shelf> 0 0 <shelf> ;

M: shelf layout* ( pile -- )
    dup shelf-gap over gadget-children run-widths >r >r
    dup gadget-children max-height r> swap pick resize-gadget
    dup gadget-children r> zip [
        uncons pick vertical-layout
    ] each drop ;

! A border lays out its children on top of each other, all with
! a 5-pixel padding.
TUPLE: border size delegate ;

C: border ( delegate size -- border )
    [ set-border-size ] keep [ set-border-delegate ] keep ;

: standard-border ( child delegate -- border )
    5 <border> [ over [ add-gadget ] [ 2drop ] ifte ] keep ;

: empty-border ( child -- border )
    <empty-gadget> standard-border ;

: bevel-border ( child -- border )
    3 0 0 0 0 <bevel-rect> <gadget> standard-border ;

: size-border ( border -- )
    dup gadget-children
    dup max-width pick border-size 2 * +
    swap max-height pick border-size 2 * +
    rot resize-gadget ;

: layout-border-x/y ( border -- )
    dup gadget-children [
        >r border-size dup r> move-gadget
    ] each-with ;

: layout-border-w/h ( border -- )
    [
        dup shape-h over border-size 2 * - >r
        dup shape-w swap border-size 2 * - r>
    ] keep
    gadget-children [ >r 2dup r> resize-gadget ] each 2drop ;

M: border layout* ( border -- )
    dup size-border dup layout-border-x/y layout-border-w/h ;

! A stack just lays out all its children on top of each other.
TUPLE: stack delegate ;
C: stack ( list -- stack )
    <empty-gadget>
    over set-stack-delegate
    swap [ over add-gadget ] each ;

M: stack layout* ( stack -- )
    dup gadget-children dup max-width swap max-height
    rot 3dup resize-gadget
    gadget-children [
        >r 2dup r> resize-gadget
    ] each 2drop ;
