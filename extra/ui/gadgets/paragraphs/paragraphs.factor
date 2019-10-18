! Copyright (C) 2005, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets ui.gadgets.labels ui.render kernel math
namespaces sequences ;
IN: ui.gadgets.paragraphs

! A word break gadget
TUPLE: word-break-gadget ;

: <word-break-gadget> ( gadget -- gadget )
    { set-delegate } word-break-gadget construct ;

M: word-break-gadget draw-gadget* drop ;

! A gadget that arranges its children in a word-wrap style.
TUPLE: paragraph margin ;

: <paragraph> ( margin -- gadget )
    paragraph construct-gadget
    { 1 0 } over set-gadget-orientation
    [ set-paragraph-margin ] keep ;

SYMBOL: x SYMBOL: max-x

SYMBOL: y SYMBOL: max-y

SYMBOL: line-height

SYMBOL: margin

: overrun? ( width -- ? ) x get + margin get > ;

: zero-vars [ 0 swap set ] each ;

: wrap-line ( -- )
    line-height get y +@
    { x line-height } zero-vars ;

: wrap-pos ( -- pos ) x get y get 2array ; inline

: advance-x ( x -- )
    x +@
    x get max-x [ max ] change ;

: advance-y ( y -- )
    dup line-height [ max ] change
    y get + max-y [ max ] change ;

: wrap-step ( quot child -- )
    dup pref-dim [
        over word-break-gadget? [
            dup first overrun? [ wrap-line ] when
        ] unless drop wrap-pos rot call
    ] keep first2 advance-y advance-x ; inline

: wrap-dim ( -- dim ) max-x get max-y get 2array ;

: init-wrap ( paragraph -- )
    paragraph-margin margin set
    { x max-x y max-y line-height } zero-vars ;

: do-wrap ( paragraph quot -- dim )
    [
        swap dup init-wrap
        [ wrap-step ] curry* each-child wrap-dim
    ] with-scope ; inline

M: paragraph pref-dim*
    [ 2drop ] do-wrap ;

M: paragraph layout*
    [ swap dup prefer set-rect-loc ] do-wrap drop ;
