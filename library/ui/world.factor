! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: errors freetype gadgets-layouts generic hashtables kernel
math namespaces opengl sequences ;

! The world gadget is the top level gadget that all (visible)
! gadgets are contained in.

! fonts: mapping font tuples to sprite vectors
! handle: native resource
TUPLE: world status focus fonts handle ;

: free-fonts ( world -- )
    dup world-handle select-gl-context
    world-fonts dup hash-values [ free-sprites ] each
    clear-hash ;

: font-sprites ( font world -- sprites )
    world-fonts [ drop V{ } clone ] cache ;

: add-status ( status world -- )
    [ set-world-status ] 2keep @bottom frame-add ;

C: world ( gadget status -- world )
    dup delegate>frame
    t over set-gadget-root?
    H{ } clone over set-world-fonts
    [ add-status ] keep
    [ @center frame-add ] keep ;

GENERIC: find-world ( gadget -- world )

M: f find-world ;

M: gadget find-world gadget-parent find-world ;

M: world find-world ;

M: world pref-dim* ( world -- dim )
    delegate pref-dim* { 1024 768 0 } vmin ;

: focused-ancestors ( world -- seq )
    world-focus parents reverse-slice ;
