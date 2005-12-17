IN: gadgets-layouts
USING: arrays gadgets gadgets-labels generic kernel math
namespaces sequences ;

! A word break gadget
TUPLE: break ;

C: break ( -- gadget ) " " <label> over set-delegate ;

! A gadget that arranges its children in a word-wrap style.
TUPLE: paragraph margin ;

C: paragraph ( margin -- gadget )
    [ set-paragraph-margin ] keep dup delegate>gadget ;

SYMBOL: x SYMBOL: max-x

SYMBOL: y SYMBOL: max-y

SYMBOL: margin

: overrun? ( width -- ? ) x get + margin get >= ;

: wrap-line ( height -- ) 0 x set y [ + ] change ;

: wrap-pos ( -- pos ) x get y get 0 3array ;

: advance-x ( x -- ) x [ + dup ] change max-x [ max ] change ;

: advance-y ( y -- ) y get + max-y [ max ] change ;

: wrap-step ( quot child -- | quot: pos child -- )
    dup pref-dim [
        over break? [
            dup first overrun? [ dup second wrap-line ] when
        ] unless drop wrap-pos rot call
    ] keep first2 advance-y advance-x ; inline

: wrap-dim ( -- dim ) max-x get max-y get 0 3array ;

: init-wrap ( paragraph -- )
    paragraph-margin margin set
    0 { x max-x y max-y } [ set ] each-with ;

: do-wrap ( paragraph quot -- dim | quot: pos child -- )
    [
        swap dup init-wrap
        gadget-children [ wrap-step ] each-with wrap-dim
    ] with-scope ; inline

M: paragraph pref-dim ( paragraph -- dim )
    [ 2drop ] do-wrap ;

M: paragraph layout* ( paragraph -- )
    [ swap dup prefer set-rect-loc ] do-wrap drop ;
