! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors documents.elements kernel math math.vectors
sequences ui.gadgets ui.gadgets.editors ui.gadgets.glass
ui.gadgets.tracks ui.gadgets.wrappers
ui.gadgets.worlds ui.gestures ;
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

CONSTANT: popup-offset { -4 0 }

: (popup-loc) ( interactor element -- loc )
    [ drop screen-loc ] [
        [
            [ [ editor-caret ] [ model>> ] bi ] dip
            prev-elt
        ] [ drop ] 2bi
        loc>point
    ] 2bi v+ popup-offset v+ ;

: popup-loc-1 ( interactor element -- loc )
    [ (popup-loc) ] [ drop caret-dim ] 2bi v+ ;

: popup-loc-2 ( interactor element popup -- loc )
    [ (popup-loc) ] dip pref-dim { 0 1 } v* v- ;

: popup-fits? ( interactor element popup -- ? )
    [ [ popup-loc-1 ] dip pref-dim v+ ]
    [ 2drop find-world dim>> ]
    3bi [ second ] bi@ <= ;

: popup-loc ( popup -- loc )
    [ interactor>> ] [ element>> ] [ ] tri 3dup popup-fits?
    [ drop popup-loc-1 ] [ popup-loc-2 ] if ;

: show-popup ( interactor element popup -- )
    <popup>
    [ dup interactor>> (>>popup) ]
    [ [ interactor>> find-world ] [ ] [ popup-loc ] tri show-glass ]
    bi ;