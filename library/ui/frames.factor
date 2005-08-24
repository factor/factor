! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: gadgets generic kernel lists math namespaces sdl
sequences vectors words ;

SYMBOL: x
SYMBOL: y

! A frame arranges left/right/top/bottom gadgets around a
! center gadget, which gets any leftover space.
TUPLE: frame left right top bottom center ;

: add-center ( gadget frame -- )
    dup frame-center unparent 2dup set-frame-center add-gadget ;
: add-left ( gadget frame -- )
    dup frame-left unparent 2dup set-frame-left add-gadget ;
: add-right ( gadget frame -- )
    dup frame-right unparent 2dup set-frame-right add-gadget ;
: add-top ( gadget frame -- )
    dup frame-top unparent 2dup set-frame-top add-gadget ;
: add-bottom ( gadget frame -- )
    dup frame-bottom unparent 2dup set-frame-bottom add-gadget ;

C: frame ( -- frame )
    [ <gadget> swap set-delegate ] keep
    [ <gadget> swap set-frame-center ] keep
    [ <gadget> swap set-frame-left ] keep
    [ <gadget> swap set-frame-right ] keep
    [ <gadget> swap set-frame-top ] keep
    [ <gadget> swap set-frame-bottom ] keep ;

: frame-major ( frame -- list )
    [
        dup frame-top , dup frame-center , frame-bottom ,
    ] make-list ;

: frame-minor ( frame -- list )
    [
        dup frame-left , dup frame-center , frame-right ,
    ] make-list ;

: pref-size pref-dim 3unseq drop ;

: max-h pref-size nip height [ max ] change ;
: max-w pref-size drop width [ max ] change ;

: add-h pref-size nip height [ + ] change ;
: add-w pref-size drop width [ + ] change ;

: with-pref-size ( quot -- )
    [
        0 width set 0 height set call width get height get
    ] with-scope ; inline

M: frame pref-dim ( glue -- dim )
    [
        dup frame-major [ max-w ] each
        dup frame-minor [ max-h ] each
        dup frame-left add-w
        dup frame-right add-w
        dup frame-top add-h
        frame-bottom add-h
    ] with-pref-size 0 3vector ;

SYMBOL: frame-right-run
SYMBOL: frame-bottom-run

: var-frame-x [ execute pref-size drop ] keep set ; inline
: var-frame-y [ execute pref-size nip ] keep set ; inline
: var-frame-left \ frame-left var-frame-x ;
: var-frame-top \ frame-top var-frame-y ;
: var-frame-right
    dup \ frame-right var-frame-x
    swap rect-dim first \ frame-right [ - ] change
    \ frame-right get \ frame-left get - frame-right-run set ;
: var-frame-bottom
    dup \ frame-bottom var-frame-y
    swap rect-dim second \ frame-bottom [ - ] change
    \ frame-bottom get \ frame-top get - frame-bottom-run set ;

: setup-frame ( frame -- )
    dup var-frame-left
    dup var-frame-top
    dup var-frame-right
    var-frame-bottom ;

: move-gadget ( x y gadget -- )
    >r 0 3vector r> set-rect-loc ;

: reshape-gadget ( x y w h gadget -- )
    [ >r 0 3vector r> set-gadget-dim ] keep move-gadget ;

: pos-frame-center
    >r \ frame-left get \ frame-top get
    \ frame-right-run get \ frame-bottom-run get r>
    reshape-gadget ;

: pos-frame-left
    [
        >r 0 \ frame-top get r> pref-size drop \ frame-bottom-run get
    ] keep reshape-gadget ;

: pos-frame-right
    [
        >r \ frame-right get \ frame-top get r> pref-size drop
        \ frame-bottom-run get
    ] keep reshape-gadget ;

: pos-frame-top
    [
        >r \ frame-left get 0 \ frame-right get r> pref-size nip
    ] keep reshape-gadget ;

: pos-frame-bottom
    [
        >r \ frame-left get \ frame-bottom get \ frame-right get
        r> pref-size nip
    ] keep reshape-gadget ;

: layout-frame ( frame -- )
    dup frame-center pos-frame-center
    dup frame-left pos-frame-left
    dup frame-right pos-frame-right
    dup frame-top pos-frame-top
    frame-bottom pos-frame-bottom ;

M: frame layout* ( frame -- )
    [ 0 x set 0 y set dup setup-frame layout-frame ] with-scope ;
