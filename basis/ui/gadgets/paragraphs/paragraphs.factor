! Copyright (C) 2005, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order sequences wrap arrays fry
ui.gadgets ui.gadgets.labels ui.render ;
IN: ui.gadgets.paragraphs

MIXIN: word-break

! A word break gadget
TUPLE: word-break-gadget < label ;

: <word-break-gadget> ( text -- gadget )
    word-break-gadget new-label ;

M: word-break-gadget draw-gadget* drop ;

INSTANCE: word-break-gadget word-break

! A gadget that arranges its children in a word-wrap style.
TUPLE: paragraph < gadget margin ;

: <paragraph> ( margin -- gadget )
    paragraph new-gadget
    horizontal >>orientation
    swap >>margin ;

<PRIVATE

: gadget>word ( gadget -- word )
    [ ] [ pref-dim first ] [ word-break? ] tri <word> ;

: wrap-paragraph ( paragraph -- wrapped-paragraph )
    [ children>> [ gadget>word ] map ] [ margin>> ] bi wrap ;

: line-width ( wrapped-line -- n )
    [ break?>> ] trim-tail-slice [ width>> ] sigma ;

: max-line-width ( wrapped-paragraph -- x )
    [ line-width ] [ max ] map-reduce ;

: line-height ( wrapped-line -- ys )
    [ key>> pref-dim second ] [ max ] map-reduce ;

: sum-line-heights ( wrapped-paragraph -- y )
    [ line-height ] sigma ;

M: paragraph pref-dim*
    wrap-paragraph [ max-line-width ] [ sum-line-heights ] bi 2array ;

: line-y-coordinates ( wrapped-paragraph -- ys )
    0 [ line-height + ] accumulate nip ;

: word-x-coordinates ( wrapped-line -- xs )
    0 [ width>> + ] accumulate nip ;

: layout-word ( word x y -- )
    [ key>> ] 2dip 2array >>loc prefer ;

: layout-line ( wrapped-line y -- )
    [
        [ ]
        [ word-x-coordinates ]
        [ [ key>> ] map baseline-align ] tri
    ] dip '[ _ + layout-word ] 3each ;

M: paragraph layout*
    wrap-paragraph dup line-y-coordinates
    [ layout-line ] 2each ;

PRIVATE>