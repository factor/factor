! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors documents.elements kernel math.rectangles
math.vectors ui.gadgets.editors ui.gadgets.glass ;
IN: ui.tools.listener.popups

: caret-loc ( interactor element -- loc )
    [
        [ [ editor-caret ] [ model>> ] bi ] dip
        prev-elt
    ] [ drop ] 2bi
    loc>point ;

: relevant-rect ( interactor element -- rect )
    [ caret-loc ] [ drop caret-dim { 0 1 } v+ ] 2bi <rect> ;

: show-listener-popup ( interactor element popup -- )
    [ [ drop ] [ relevant-rect ] 2bi ] dip swap show-popup ;
