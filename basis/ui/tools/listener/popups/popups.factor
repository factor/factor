! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors documents.elements kernel math math.vectors
math.rectangles math.rectangles.positioning sequences ui.gadgets
ui.gadgets.editors ui.gadgets.glass ui.gadgets.tracks
ui.gadgets.wrappers ui.gadgets.worlds ui.gestures ;
IN: ui.tools.listener.popups

SLOT: popup

TUPLE: popup < wrapper interactor element ;

: <popup> ( interactor element gadget -- popup )
    popup new-wrapper
        swap >>element
        swap >>interactor ;

M: popup hide-glass-hook
    interactor>> f >>popup request-focus ;

: hide-popup ( popup -- )
    find-world hide-glass ;

popup H{
    { T{ key-down f f "ESC" } [ hide-popup ] }
} set-gestures

: caret-loc ( interactor element -- loc )
    [ drop screen-loc ] [
        [
            [ [ editor-caret ] [ model>> ] bi ] dip
            prev-elt
        ] [ drop ] 2bi
        loc>point
    ] 2bi v+ ;

: relevant-rect ( popup -- rect )
    [ interactor>> ] [ element>> ] bi
    [ caret-loc ] [ drop caret-dim { 0 1 } v+ ] 2bi
    <rect> ;

: listener-popup-loc ( popup -- loc )
    [ relevant-rect ] [ pref-dim ] [ interactor>> find-world dim>> ] tri
    popup-loc ;

: show-popup ( interactor element popup -- )
    <popup>
    [ dup interactor>> (>>popup) ]
    [ [ interactor>> find-world ] [ ] [ listener-popup-loc ] tri show-glass ]
    bi ;