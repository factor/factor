! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences kernel gadgets-panes definitions
prettyprint gadgets-theme gadgets-borders gadgets
generic gadgets-scrolling math io words models styles
namespaces gadgets-tracks gadgets-presentations
gadgets-workspace help gadgets-buttons gadgets-tracks
gadgets-slots tools ;
IN: gadgets-tiles

TUPLE: tile object pane printer ;

: refresh ( inspector -- )
    dup tile-object over tile-pane rot tile-printer with-pane ;

C: tile ( obj printer -- inspector )
    [ set-tile-printer ] keep
    [ set-tile-object ] keep
    [
        [
            toolbar,
            <pane> g-> set-tile-pane 1 track,
        ] { 0 1 } make-track 2 <border>
    ] "" build-closable-gadget
    dup faint-boundary
    dup refresh ;

\ tile "toolbar" f {
    { T{ update-object } refresh }
} define-command-map
