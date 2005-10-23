IN: polynomial-internals
USING: kernel sequences vectors math math-internals namespaces ;

: 2length ( seq seq -- ) [ length ] 2apply ;

: zero-vector ( n -- vector ) 0 <repeated> >vector ;

: nzero-pad ( n seq -- seq )
    #! extend seq by n zeros
    >r zero-vector r> swap nappend ;

: zero-pad ( n seq -- seq )
    #! extend seq by n zeros
    >r zero-vector r> swap append ;

: zero-pad-front ( n seq -- seq )
    >r zero-vector r> append ;

: zero-extend ( n seq -- )
    #! extend seq to max(n,length) with 0s
    [ length ] keep -rot - swap nzero-pad ;

: 2zero-extend ( seq seq -- )
    2dup max-length [ swap zero-extend ] keep swap zero-extend ;

: pextend ( p p -- p p )
    2dup 2zero-extend ;

IN: math-contrib

: p= ( p p -- )
    pextend = ;

: ptrim ( p -- p )
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

: conv ( p p -- p )
    conv*a [ 3dup -rot v* sum >r pick r> -rot set-nth conv*b ] repeat nip ;

! polynomial multiply
: p* ( p p -- p )
    conv ;

: p-sq ( p -- p-sq )
    dup p* ;

IN: polynomial-internals

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

IN: math

: p/mod
    p/mod-setup [ [ (p/mod) ] times ] { } make reverse nip swap 2ptrim pextend ;

: (pgcd) ( b a y x -- a d )
    dup { 0 } clone p= [
        drop nip
    ] [
        tuck p/mod >r pick p* swap >r swapd p- r> r> (pgcd)
    ] if ;
    
: pgcd ( p p -- p )
    swap { 0 } clone { 1 } clone 2swap (pgcd) ;

