IN: polynomials-internals
USING: arrays kernel sequences vectors math math-internals namespaces arrays
    sequences-contrib ;

! Polynomials are vectors with the highest powers on the right:
! { 1 1 0 1 } -> 1 + x + x^3
! { } -> 0

: 2pad-left ( p p n -- p p ) 0 [ pad-left swap ] 2keep pad-left swap ;
: 2pad-right ( p p n -- p p ) 0 [ pad-right swap ] 2keep pad-right swap ;
: pextend ( p p -- p p ) 2dup [ length ] 2apply max 2pad-right ;
: pextend-left ( p p -- p p ) 2dup [ length ] 2apply max 2pad-left ;
: unempty ( seq -- seq ) dup empty? [ drop { 0 } ] when ;
: 2unempty ( seq seq -- seq seq ) [ unempty ] 2apply ;

IN: math-contrib
: p= ( p p -- ? ) pextend = ;

: ptrim ( p -- p ) [ zero? ] rtrim* ;

: 2ptrim ( p p -- p p ) [ ptrim ] 2apply ;
: p+ ( p p -- p ) pextend v+ ;
: p- ( p p -- p ) pextend v- ;
: n*p ( n p -- n*p ) n*v ;

! convolution
: pextend-conv ( p p -- p p )
    #! extend to: p_m + p_n - 1 
    2dup [ length ] 2apply + 1- 2pad-right [ >vector ] 2apply ;

: p* ( p p -- p )
    #! Multiply two polynomials.
    2unempty pextend-conv <reversed> dup length
    [ over length pick <slice> pick [ * ] 2map sum ] map 2nip reverse ;
    
: p-sq ( p -- p-sq )
    dup p* ;

IN: polynomials-internals

: pop-front ( seq -- seq )
    1 tail-slice ;

: /-last ( seq seq -- a )
    #! divide the last two numbers in the sequences
    [ peek ] 2apply / ;

: p/mod-setup ( p p -- p p n )
    2ptrim 2dup [ length ] 2apply - dup 1 < [ drop 1 ] when
    dup >r over length + 0 pad-left pextend r> 1+ ;

: (p/mod)
    2dup /-last 2dup , n*p swapd p- >vector dup pop drop swap pop-front ;

IN: math-contrib
: p/mod
    p/mod-setup [ [ (p/mod) ] times ] V{ } make
    reverse nip swap 2ptrim pextend ;

: (pgcd) ( b a y x -- a d )
    dup V{ 0 } clone p= [
        drop nip
    ] [
        tuck p/mod >r pick p* swap >r swapd p- r> r> (pgcd)
    ] if ;

: pgcd ( p p -- p q )
    swap V{ 0 } clone V{ 1 } clone 2swap (pgcd) [ >array ] 2apply ;

: pdiff ( p -- p' )
    #! Polynomial derivative.
    dup length v* { 0 } ?head drop ;

: polyval ( p x -- p[x] )
    #! Evaluate a polynomial.
    >r dup length r> powers v. ;
