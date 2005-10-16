USING: kernel sequences vectors math math-internals ;

USING: prettyprint inspector io test ;

! p+ p- n*p p* p/mod pgcd

IN: math
: max-length ( seq seq -- n )
    [ length ] 2apply max ; flushable

IN: math-internals
: 2length ( seq seq -- ) >r length r> length ;

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

IN: math

: ptrim ( p -- p )
    dup length 1 > [ dup peek 0 = [ dup pop drop ptrim ] when ] when ;
: 2ptrim ( p -- p )
    ptrim >r ptrim r> ;

: pextend ( p p -- p p )
    2dup 2zero-extend ;

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

IN: math-internals
: (nth-div) ( n v1 v2 -- a )
    #! get nth from end
    rot 1+ >r 2dup 2length r> swap over - >r - r> rot nth >r swap nth r> ;

: nth-divi ( n v1 v2 -- a )
    #! get nth from end
    (nth-div) /i ;

: nth-div
    (nth-div) / ;

: shift-seq-left ( seq -- seq )
    ! 1 over [ length ] keep <slice> [ change-nth ]
    reverse dup pop drop reverse 0 over push ;

: p/mod-a ( u v -- q u v i )
    #! set up the stack
    2ptrim 2dup 2length - dup 1 < [ drop 1 ] when
    dup >r swap zero-pad-front r> 1+ dup >r zero-vector -rot pextend r> ;
    
: p/mod-b
    >r >r pick r> r> swapd pick pick length swap - 1- rot
    pick >r set-nth r> swap >r over n*p rot swap v- swap shift-seq-left r> ;

IN: math

: p/modi ( u v -- q r )
    #! integer coefficients
    p/mod-a [ 3dup -rot nth-divi p/mod-b ] repeat drop 2ptrim pextend ;

: p/mod ( u v -- q r )
    #! non-integer coefficients
    p/mod-a [ 3dup -rot nth-div p/mod-b ] repeat drop 2ptrim pextend ;

: p= ( p p -- )
    pextend = ;
    
: (pgcd) ( b a y x -- a d )
    dup { 0 } p= [
        drop nip
    ] [
        tuck p/modi >r pick p* swap >r swapd p- r> r> (pgcd)
    ] if ;
    
: pgcd ( p p -- p )
    swap { 0 } { 1 } 2swap (pgcd) ;

: test-p*
    100000 [ drop { 1 1 1 } { 1 1 1 } p* drop ] each ;

: test-polynomial
    [ { 0 1 } ] [ { 0 1 0 0 } ptrim ] unit-test
    [ { 1 } ] [ { 1 0 0 } ptrim ] unit-test
    [ { 0 } ] [ { 0 } ptrim ] unit-test
    [ { 3 10 8 } ] [ { 1 2 } { 3 4 } p* ] unit-test
    [ { 3 10 8 } ] [ { 3 4 } { 1 2 } p* ] unit-test
    [ { 0 0 0 0 0 0 0 0 0 0 } ] [ { 0 0 0 } { 0 0 0 0 0 0 0 0 } p* ] unit-test
    [ { 0 1 } ] [ { 0 1 } { 1 } p* ] unit-test
    [ { 0 0 0 } ] [ { 0 0 0 } { 0 0 0 } p+ ] unit-test
    [ { 0 0 0 } ] [ { 0 0 0 } { 0 0 0 } p- ] unit-test
    [ { 0 0 0 } ] [ 4 { 0 0 0 } n*p ] unit-test
    [ { 4 8 0 12 } ] [ 4 { 1 2 0 3 } n*p ] unit-test
    [ { 1 4 7 6 0 0 0 0 0 } ] [ { 1 2 3 0 0 0 } { 1 2 0 0 } conv ] unit-test
    [ { 1 4 7 6 0 0 0 0 0 } ] [ { 1 2 3 0 0 0 } { 1 2 0 0 } p* ] unit-test
    [ { 7 -2 1 } { -20 0 0 } ] [ { 1 1 1 1 } { 3 1 } p/modi ] unit-test
    [ { 1 0 1 } { 0 0 0 } ] [ { 1 1 1 1 } { 1 1 } p/modi ] unit-test
    [ { 1 0 1 } { 0 0 0 } ] [ { 1 1 1 1 } { 1 1 0 0 0 0 0 0 } p/modi ] unit-test
    [ { 1 0 1 } { 0 0 0 } ] [ { 1 1 1 1 0 0 0 0 } { 1 1 0 0 } p/modi ] unit-test
    [ { 5.0 } { 0.0 } ] [ { 10.0 } { 2.0 } p/mod ] unit-test
    [ { 15/16 } { 0 } ] [ { 3/4 } { 4/5 } p/mod ] unit-test
    [ t ] [ { 0 1 } { 0 1 0 } p= ] unit-test
    [ f ] [ { 0 0 1 } { 0 1 0 } p= ] unit-test
    [ t ] [ { 1 1 1 } { 1 1 1 } p= ] unit-test
    [ { 0 0 } { 1 1 } ] [ { 1 1 1 1 } { 1 1 } pgcd ] unit-test
    ;

