IN: math-contrib

USING: kernel sequences errors namespaces math lists vectors ;

SYMBOL: step-size .01 step-size set
SYMBOL: num-steps 180 num-steps set ! simpsons

: setup-range ( from to -- frange )
    step-size get swap <frange> ;

: integrate-rect ( from to f -- x )
    >r setup-range dup decrement-length r>
    [ step-size get * ] append map sum ;

: integrate-trap ( from to f -- x )
    >r setup-range r>
    map 1 over tail >r >vector dup pop drop r>
    [ + 2 / step-size get * ] 2map sum ;


: setup-simpson-range ( from to -- frange )
    [ swap - num-steps get /f ] 2keep swapd <frange> ;

: generate-simpson-weights ( seq -- seq )
    length 2 / V{ 1 4 } clone swap 2 -
    [ { 2 4 } append ] times { 1 } append ;


! take elements n at a time and apply the quotation, forming a new seq
: group-map ( seq n quot -- seq )
    pick length pick /
    [ [ >r pick pick r> -rot pick over * [ + ] keep swap rot <slice> pick call 
    , ] repeat ] { } make 2nip nip ;

: nths ( n seq -- seq )
    2dup length 0 -rot <frange> dup decrement-length [ over nth ] map 2nip ;

! broken
! take a set of every nth element and apply the quotation, forming a new seq
! { 1 2 3 4 5 6 } 3 [ sum ] ->  { 1 4 } { 2 5 } { 3 6 } -> { 5 7 9 }
! : skip-map ( seq n quot -- seq )
    ! pick length pick / [ 1+ >r pick r> swap dupd nths 1- ] repeat ;

: integrate-simpson ( from to f -- x )
    >r setup-simpson-range r> dupd map dup generate-simpson-weights
    [ * ] 2map sum swap [ third ] keep first - 6 / * ; 

