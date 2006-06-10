! Copyright (C) 2005, 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-paragraphs
USING: arrays gadgets gadgets-labels generic kernel math
namespaces sequences ;

! A word break gadget
TUPLE: word-break-gadget ;

C: word-break-gadget ( gadget -- gadget )
    [ set-delegate ] keep ;

! A gadget that arranges its children in a word-wrap style.
TUPLE: paragraph margin ;

C: paragraph ( margin -- gadget )
    [ set-paragraph-margin ] keep dup delegate>gadget ;

SYMBOL: x SYMBOL: max-x

SYMBOL: y SYMBOL: max-y

SYMBOL: line-height

SYMBOL: margin

: overrun? ( width -- ? ) x get + margin get >= ;

: wrap-line ( -- )
    line-height get y +@
    0 { x line-height } [ set ] each-with ;

: wrap-pos ( -- pos ) x get y get 0 3array ;

: advance-x ( x -- )
    x +@
    x get max-x [ max ] change ;

: advance-y ( y -- )
    dup line-height [ max ] change
    y get + max-y [ max ] change ;

: wrap-step ( quot child -- | quot: pos child -- )
    dup pref-dim [
        over word-break-gadget? [
            dup first overrun? [ wrap-line ] when
        ] unless drop wrap-pos rot call
    ] keep first2 advance-y advance-x ; inline

: wrap-dim ( -- dim ) max-x get max-y get 0 3array ;

: init-wrap ( paragraph -- )
    paragraph-margin margin set
    0 { x max-x y max-y line-height } [ set ] each-with ;

: do-wrap ( paragraph quot -- dim | quot: pos child -- )
    [
        swap dup init-wrap
        [ wrap-step ] each-child-with wrap-dim
    ] with-scope ; inline

M: paragraph pref-dim* ( paragraph -- dim )
    [ 2drop ] do-wrap ;

M: paragraph layout* ( paragraph -- )
    [ swap dup prefer set-rect-loc ] do-wrap drop ;
