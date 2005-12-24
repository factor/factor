IN: polynomials-internals
USING: kernel sequences vectors math math-internals namespaces arrays ;

! Polynomials are vectors with the highest powers on the right:
! { 1 1 0 1 } -> 1 + x + x^3
! { } -> 0

: 2length ( seq seq -- ) [ length ] 2apply ;

: zero-vector ( n -- vector ) zero-array >vector ;

: zero-pad ( n seq -- seq )
    #! extend seq by n zeros
    >r zero-vector r> swap append ;

: zero-pad-front ( n seq -- seq )
    >r zero-vector r> append ;

: nzero-pad ( n seq -- )
    #! extend seq by n zeros
    >r zero-vector r> swap nappend ;

: zero-extend ( n seq -- )
    #! extend seq to max(n,length) with 0s
    [ length ] keep -rot - swap nzero-pad ;

: 2zero-extend ( seq seq -- )
    2dup max-length [ swap zero-extend ] keep swap zero-extend ;

: pextend ( p p -- p p )
    #! make two polynomials the same length, if empty, make length 1
    [ >vector ] 2apply 2dup 2zero-extend  ;

: unempty ( seq seq -- )
    #! turn { } into { 0 }
    dup empty? [ 1 swap zero-pad ] when ;
    
: 2unempty ( seq seq -- )
    [ unempty ] 2apply ;

IN: math-contrib

: p= ( p p -- )
    pextend = ;

: ptrim ( p -- p )
    >vector
    dup length 1 > [ dup peek 0 = [ dup pop drop ptrim ] when ] when ;

: 2ptrim ( p -- p )
    [ ptrim ] 2apply ;

: p+ ( p p -- p )
    pextend v+ ;

: p- ( p p -- p )
    pextend v- ;

: n*p ( n p -- n*p )
    n*v ;

! convolution
: (conv*a)
    2dup swap length - rot zero-pad-front ;

: conv*a ( seq seq -- seq seq )
    2dup 2length + 1- (conv*a) reverse -rot (conv*a) swap ;

: conv*b ( seq -- seq )
    rot dup pop drop 1 zero-vector swap append -rot ;

: p* ( p p -- p )
    #! Multiply two polynomials.
    2unempty conv*a [ 3dup -rot v* sum >r pick r> -rot set-nth conv*b ] repeat nip ;

: p-sq ( p -- p-sq )
    dup p* ;

IN: polynomials-internals

: pop-front ( seq -- seq )
    1 swap tail ;

: /-last ( seq seq -- a )
    #! divide the last two numbers in the sequences
    [ peek ] 2apply /i ;

: p/mod-setup
    2ptrim 2dup 2length - dup 1 < [ drop 1 ] when
    dup >r swap zero-pad-front pextend r> 1+ ;

: (p/mod)
    2dup /-last 2dup , n*p swapd p- dup pop drop swap pop-front ;

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
    
: pgcd ( p p -- p )
    swap V{ 0 } clone V{ 1 } clone 2swap (pgcd) ;

: pdiff ( p -- p' )
    #! Polynomial derivative.
    dup empty? [ [ length ] keep v* 1 swap tail ] unless ;

: polyval ( x p -- p[x] )
    #! Evaluate a polynomial.
    [ powers ] keep v. ;
