! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math matrices
namespaces sdl sequences ;

: layout ( gadget -- )
    #! Set the gadget's width and height to its preferred width
    #! and height. The gadget's children are laid out first.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        f over set-gadget-relayout?
        dup gadget-paint [
            dup layout*
            gadget-children [ layout ] each
        ] bind
    ] [
        drop
    ] ifte ;

GENERIC: alignment
GENERIC: filling
GENERIC: orientation

: pref-dims ( gadget -- list )
    gadget-children [ pref-dim ] map ;

: orient ( gadget list1 list2 -- list )
    zip >r orientation r> [ uncons rot set-axis ] map-with ;

: packed-dim-2 ( gadget sizes -- list )
    [ over shape-dim { 1 1 1 } vmax over v- rot filling v*n v+ ] map-with ;

: (packed-dims) ( gadget sizes -- list )
    2dup packed-dim-2 swap orient ;

: packed-dims ( gadget sizes -- list )
    over gadget-children >r (packed-dims) r>
    zip [ uncons set-gadget-dim ] each ;

: packed-loc-1 ( sizes -- list )
    { 0 0 0 } [ v+ ] accumulate ;

: packed-loc-2 ( gadget sizes -- list )
    >r dup shape-dim { 1 1 1 } vmax over r> packed-dim-2 [ v- ] map-with
    >r dup alignment swap shape-dim { 1 1 1 } vmax r>
    [ >r 2dup r> v- n*v ] map 2nip ;

: (packed-locs) ( gadget sizes -- list )
    dup packed-loc-1 >r dupd packed-loc-2 r> orient ;

: packed-locs ( gadget sizes -- )
    over gadget-children >r (packed-locs) r>
    zip [ uncons set-gadget-loc ] each ;

: packed-layout ( gadget sizes -- )
    2dup packed-locs packed-dims ;

TUPLE: pack align fill vector ;

C: pack ( align fill vector -- pack )
    #! align: 0 left aligns, 1/2 center, 1 right.
    #! gap: between each child.
    #! fill: 0 leaves default width, 1 fills to pack width.
    [ <empty-gadget> swap set-delegate ] keep
    [ set-pack-vector ] keep
    [ set-pack-fill ] keep
    [ set-pack-align ] keep ;

: <pile> { 0 1 0 } <pack> ;

: <line-pile> 0 1 <pile> ;

: <shelf> { 1 0 0 } <pack> ;

: <line-shelf> 0 1 <shelf> ;

M: pack orientation pack-vector ;

M: pack filling pack-fill ;

M: pack alignment pack-align ;

M: pack pref-dim ( pack -- dim )
    [
        pref-dims
        [ { 0 0 0 } [ vmax ] reduce ] keep
        { 0 0 0 } [ v+ ] reduce
    ] keep orientation set-axis ;

M: pack layout* ( pack -- )
    dup pref-dims packed-layout ;

: <stack> ( list -- gadget )
    #! A stack lays out all its children on top of each other.
    0 1 { 0 0 1 } <pack>  swap [ over add-gadget ] each ;
