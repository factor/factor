IN: math-contrib

USING: kernel sequences errors namespaces math lists vectors ;

SYMBOL: step-size .01 step-size set

: setup-range ( from to -- frange )
    step-size get swap <frange> ;

: integrate-rect ( from to f -- x )
    >r setup-range dup decrement-length r>
    [ step-size get * ] append map sum ;

: integrate-trap ( from to f -- x )
    >r setup-range r>
    map 1 over tail >r >vector dup pop drop r>
    [ + 2 / step-size get * ] 2map sum ;

! : integrate-simpson ( from to f -- x )
    ! >r setup-range r> ;
    

