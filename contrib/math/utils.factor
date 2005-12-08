IN: math-contrib
USING: errors kernel sequences math sequences-internals namespaces arrays ;

: deg>rad pi * 180 / ; inline
: rad>deg 180 * pi / ; inline

: lcm ( a b -- c )
    #! Smallest integer such that c/a and c/b are both integers.
    2dup gcd nip >r * r> /i ; foldable

: mod-inv ( x n -- y )
    #! Compute the multiplicative inverse of x mod n.
    gcd 1 = [ "Non-trivial divisor found" throw ] unless ;
    foldable

: (^mod) ( n z w -- z^w )
    1 swap [
        1 number= [ dupd * pick mod ] when >r sq over mod r>
    ] each-bit 2nip ; inline

: ^mod ( z w n -- z^w )
    #! Compute z^w mod n.
    over 0 < [
        [ >r neg r> ^mod ] keep mod-inv
    ] [
        -rot (^mod)
    ] if ; foldable

: powers ( x n -- { 1 x x^2 x^3 ... } )
    #! Output sequence has n elements.
    1 swap [ drop [ dupd * ] keep ] map 2nip ;

: ** ( u v -- u*v' ) conjugate * ; inline

: c. ( v v -- x )
    #! Complex inner product.
    0 [ ** + ] 2reduce ;

: minmax ( seq -- min max )
    #! find the min and max of a seq in one pass
    inf -inf rot [ dup pick max -rot nip pick min -rot nip ] each ;

: absminmax ( seq -- min max )
    #! find the absolute values of the min and max of a seq in one pass
    minmax 2dup [ abs ] 2apply > [ swap ] when ;

SYMBOL: almost=-precision .000001 almost=-precision set
: almost= ( a b -- bool )
    2dup - abs almost=-precision get < [
            2drop t
        ] [
            2array absminmax dup almost=-precision get * >r - abs r>
            dup 0 < [ >= ] [ <= ] if
    ] if ;

TUPLE: frange from step length ;

C: frange ( from step to -- seq )
    #! example: 0 .01 10 <frange> >array
    >r pick - swap [ / ceiling 1+ ] keep -rot swapd r> 
    [ set-frange-length ] keep
    [ set-frange-step ] keep
    [ set-frange-from ] keep ;

: decrement-length ( frange -- )
    [ frange-length 1- ] keep set-frange-length ;

: <frange-no-endpt> ( from step length -- seq )
    <frange> dup decrement-length ;

M: frange length ( frange -- n )
    frange-length ;

: increment-start ( frange -- )
    [ [ frange-from ] keep frange-step + ] keep set-frange-from ;

: frange-range ( frange -- range )
    [ frange-step ] keep frange-length 1- * ;

M: frange nth ( n frange -- obj ) [ frange-step * ] keep frange-from + ;
M: frange nth-unsafe ( n frange -- obj ) nth ;

: nseq-swap ( a b seq -- seq )
    #! swap indices a,b in seq
    3dup [ nth ] keep swapd [ nth ] keep
    >r >r rot r> r> swapd set-nth -rot set-nth ;

! : pivot ( left right index seq -- )
    ! [ nth ] keep [ nseq-swap ] 3keep ;

SYMBOL: step-size .01 step-size set  ! base on arguments
: (limit) ( count diff quot -- x quot )
    pick 10 > [ "Not converging fast enough" throw ] when
    [ call ] keep >r 2dup swap - 0 < [ "not converging" throw ] when
    2dup almost= rot drop r>
    swap [ step-size [ 2 / ] change rot 1+ -rot (limit) ] unless ;

: limit ( quot -- x )
    .1 step-size set [ call ] keep step-size [ 2 / ] change 0 -rot (limit) 2drop ;

! take elements n at a time and apply the quotation, forming a new seq
: group-map ( seq n quot -- seq )
    pick length pick /
    [ [ >r pick pick r> -rot pick over * [ + ] keep swap rot <slice> pick call
    , ] repeat ] { } make 2nip nip ;

: nths ( start n seq -- seq )
    -rot pick length <frange-no-endpt> [ over nth ] map nip ;

! take a set of every nth element and apply the quotation, forming a new seq
! { 1 2 3 4 5 6 } 3 [ sum ] skip-map ->  { 1 4 } { 2 5 } { 3 6 } -> { 5 7 9 }
: skip-map ( seq n quot -- seq )
    pick length pick /mod 
    0 = [ "seq length must be a multiple of n" throw ] unless
    1 <= [ "seq must be 2n or longer" throw ] when 
    over [ [ dup >r >r pick pick r> rot swapd nths over call , r> ] repeat ] { } make 2nip nip ;

