! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: errors freetype gadgets-layouts generic hashtables kernel
namespaces opengl sequences ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in.

! fonts: mapping font tuples to sprite vectors
! handle: native resource
TUPLE: world glass status focus fonts handle ;

: free-fonts ( world -- )
    dup world-handle select-gl-context
    world-fonts dup hash-values [ free-sprites ] each
    clear-hash ;

: font-sprites ( font world -- sprites )
    world-fonts [ drop V{ } clone ] cache ;

C: world ( gadget status dim -- world )
    <stack> over set-delegate
    t over set-gadget-root?
    H{ } clone over set-world-fonts
    [ set-gadget-dim ] keep
    [ set-world-status ] keep
    [ add-gadget ] keep ;

: hide-glass ( world -- )
    dup world-glass unparent f swap set-world-glass ;

: <glass> ( gadget -- glass )
    <gadget> 2dup add-gadget swap prefer ;

: show-glass ( gadget world -- )
    dup hide-glass
    >r <glass> r> 2dup add-gadget
    set-world-glass ;

GENERIC: find-world ( gadget -- world )

M: f find-world ;

M: gadget find-world gadget-parent find-world ;

M: world find-world ;

: focused-ancestors ( world -- seq )
    world-focus parents reverse-slice ;

: simple-window ( gadget title -- )
    >r f over pref-dim r> in-window ;
