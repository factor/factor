USING: gadgets kernel lists math namespaces sdl ;

! A frame arranges left/right/top/bottom gadgets around a
! center gadget, which gets any leftover space.
TUPLE: frame gap left right top bottom center ;

C: frame ( gap center -- frame )
    [ set-frame-gap ] keep
    [ set-frame-center ] keep
    [ <empty-gadget> swap set-frame-left ] keep
    [ <empty-gadget> swap set-frame-right ] keep
    [ <empty-gadget> swap set-frame-top ] keep
    [ <empty-gadget> swap set-frame-bottom ] keep ;

: frame-major ( glue -- list )
    [
        dup frame-top , dup frame-center , frame-bottom ,
    ] make-list ;

: frame-minor ( glue -- list )
    [
        dup frame-left , dup frame-center , frame-right ,
    ] make-list ;

: max-h pref-size nip height [ max ] change ;
: max-w pref-size drop width [ max ] change ;

: add-h pref-size nip height [ + ] change ;
: add-w pref-size drop width [ + ] change ;

M: frame pref-size ( glue -- w h )
    [
        dup frame-major [ max-w ] each
        dup frame-minor [ max-h ] each
        dup frame-left add-w
        dup frame-right add-w
        dup frame-top add-h
        dup frame-bottom add-h
    ] with-pref-size ;


