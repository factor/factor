! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces ;

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

: w/h ( list -- widths heights ) [ pref-size cons ] map unzip ;

: greatest ( integers -- n ) [ [ > ] top ] [ 0 ] ifte* ;

: layout-align ( align max dimensions -- offsets )
    [ >r 2dup r> - * ] map 2nip ;

: layout-fill ( fill max dimensions -- dimensions )
    [ layout-align ] keep zip [ uncons + ] map ;

: layout-run ( gap list -- n list )
    #! The nth element of the resulting list is the sum of the
    #! first n elements of the given list plus gap, n times.
    [ 0 swap [ over , + over + ] each ] make-list >r swap - r> ;

M: pile pref-size ( pile -- w h )
    dup pile-gap swap w/h swapd layout-run drop >r greatest r> ;

M: pile layout* ( pile -- )
    dup pile-gap over gadget-children run-heights >r >r
    dup gadget-children max-width r> pick resize-gadget
    dup gadget-children r> zip [
        uncons horizontal-layout
    ] each-with ;

! A shelf is a box that lays out its contents horizontally.
TUPLE: shelf gap align fill delegate ;

C: shelf ( align gap fill -- shelf )
    <empty-gadget> over set-shelf-delegate
    [ set-shelf-fill ] keep
    [ set-shelf-gap ] keep
    [ set-shelf-align ] keep ;

: h- swap shape-h swap shape-h - ;
: shelf-h 2dup h- rot shelf-fill * swap shape-h + >fixnum ;
: shelf-y dupd h- swap shelf-align * >fixnum ;

: vertical-layout ( gadget x shelf -- )
    >r 2dup shelf-h >r dup shape-w r> pick resize-gadget
    tuck shelf-y r> swap rot move-gadget ;

: <default-shelf> 1/2 default-gap 0 <shelf> ;
: <line-shelf> 0 0 1 <shelf> ;

M: shelf pref-size ( shelf -- w h )
    dup shelf-gap over gadget-children run-widths drop
    swap gadget-children max-height ;

M: shelf layout* ( shelf -- )
    dup shelf-gap over gadget-children run-widths >r >r
    dup gadget-children max-height r> swap pick resize-gadget
    dup gadget-children r> zip [
        uncons vertical-layout
    ] each-with ;

! A border lays out its children on top of each other, all with
! a 5-pixel padding.
TUPLE: border size delegate ;

C: border ( child delegate size -- border )
    [ set-border-size ] keep
    [ set-border-delegate ] keep
    [ over [ add-gadget ] [ 2drop ] ifte ] keep ;

: empty-border ( child -- border )
    <empty-gadget> 5 <border> ;

: line-border ( child -- border )
    0 0 0 0 <etched-rect> <gadget> 5 <border> ;

: filled-border ( child -- border )
    0 0 0 0 <plain-rect> <gadget> 5 <border> ;

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

M: border pref-size ( border -- w h )
    dup gadget-children
    dup max-width pick border-size 2 * +
    swap max-height rot border-size 2 * + ;

M: border layout* ( border -- )
    dup layout-border-x/y layout-border-w/h ;

! A stack just lays out all its children on top of each other.
TUPLE: stack delegate ;
C: stack ( list -- stack )
    <empty-gadget>
    over set-stack-delegate
    swap [ over add-gadget ] each ;

: max-size ( stack -- w h ) w/h swap greatest swap greatest ;

M: stack pref-size gadget-children max-size ;

M: stack layout* ( stack -- )
    dup gadget-children [
        >r dup shape-w over shape-h r> resize-gadget
    ] each drop ;
