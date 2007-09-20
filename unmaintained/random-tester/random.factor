USING: kernel math sequences namespaces errors hashtables words
arrays parser compiler syntax io tools prettyprint optimizer
inference ;
IN: random-tester

! Tweak me
: max-length 15 ; inline
: max-value 1000000000 ; inline

: 10% ( -- bool ) 10 random 8 > ;
: 20% ( -- bool ) 10 random 7 > ;
: 30% ( -- bool ) 10 random 6 > ;
: 40% ( -- bool ) 10 random 5 > ;
: 50% ( -- bool ) 10 random 4 > ;
: 60% ( -- bool ) 10 random 3 > ;
: 70% ( -- bool ) 10 random 2 > ;
: 80% ( -- bool ) 10 random 1 > ;
: 90% ( -- bool ) 10 random 0 > ;

! varying bit-length random number
: random-bits ( n -- int )
    random 2 swap ^ random ;

: random-seq ( -- seq )
    { [ ] { } V{ } "" } random
    [ max-length random [ max-value random , ] times ] swap make ;

: random-string
    [ max-length random [ max-value random , ] times ] "" make ;

SYMBOL: special-integers
[ { -1 0 1 } % most-negative-fixnum , most-positive-fixnum , first-bignum , ] 
{ } make \ special-integers set-global
: special-integers ( -- seq ) \ special-integers get ;
SYMBOL: special-floats
[ { 0.0 -0.0 } % e , pi , 1./0. , -1./0. , 0./0. , epsilon , epsilon neg , ]
{ } make \ special-floats set-global
: special-floats ( -- seq ) \ special-floats get ;
SYMBOL: special-complexes
[ 
    { -1 0 1 i -i } %
    e , e neg , pi , pi neg ,
    0 pi rect> , 0 pi neg rect> , pi neg 0 rect> , pi pi rect> ,
    pi pi neg rect> , pi neg pi rect> , pi neg pi neg rect> ,
    e neg e neg rect> , e e rect> ,
] { } make \ special-complexes set-global
: special-complexes ( -- seq ) \ special-complexes get ;

: random-fixnum ( -- fixnum )
    most-positive-fixnum random 1+ coin-flip [ neg 1- ] when >fixnum ;

: random-bignum ( -- bignum )
     400 random-bits first-bignum + coin-flip [ neg ] when ;
    
: random-integer ( -- n )
    coin-flip [
        random-fixnum
    ] [
        coin-flip [ random-bignum ] [ special-integers random ] if
    ] if ;

: random-positive-integer ( -- int )
    random-integer dup 0 < [
            neg
        ] [
            dup 0 = [ 1 + ] when
    ] if ;

: random-ratio ( -- ratio )
    1000000000 dup [ random ] 2apply 1+ / coin-flip [ neg ] when dup [ drop random-ratio ] unless 10% [ drop 0 ] when ;

: random-float ( -- float )
    coin-flip [ random-ratio ] [ special-floats random ] if
    coin-flip 
    [ .0000000000000000001 /f ] [ coin-flip [ .00000000000000001 * ] when ] if
    >float ;

: random-number ( -- number )
    {
        [ random-integer ]
        [ random-ratio ]
        [ random-float ]
    } do-one ;

: random-complex ( -- C )
    random-number random-number rect> ;

