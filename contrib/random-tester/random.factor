USING: kernel math sequences namespaces errors hashtables words arrays parser
       compiler syntax lists io ;
USING: inspector prettyprint ;
USING: optimizer compiler-frontend compiler-backend inference ;
IN: random-tester

! Tweak me
: max-length 7 ; inline
: max-value 1000000000 ; inline

: 10% ( -- bool ) 10 random-int 8 > ;
: 20% ( -- bool ) 10 random-int 7 > ;
: 30% ( -- bool ) 10 random-int 6 > ;
: 40% ( -- bool ) 10 random-int 5 > ;
: 50% ( -- bool ) 10 random-int 4 > ;
: 60% ( -- bool ) 10 random-int 3 > ;
: 70% ( -- bool ) 10 random-int 2 > ;
: 80% ( -- bool ) 10 random-int 1 > ;
: 90% ( -- bool ) 10 random-int 0 > ;

! varying bit-length random number
: random-bits ( n -- int )
    random-int 2 swap ^ random-int ;

: random-seq ( -- seq )
    { [ ] { } V{ } "" } nth-rand
    [ max-length random-int [ max-value random-int , ] times ] swap make ;

: random-string
    [ max-length random-int [ max-value random-int , ] times ] "" make ;

SYMBOL: special-integers
[ { -1 0 1 } % most-negative-fixnum , most-positive-fixnum , first-bignum , ] 
{ } make \ special-integers set
: special-integers ( -- seq ) \ special-integers get ;
SYMBOL: special-floats
[ { 0.0 -0.0 } % e , pi , 1./0. , -1./0. , 0./0. , epsilon , epsilon neg , ]
{ } make \ special-floats set
: special-floats ( -- seq ) \ special-floats get ;
SYMBOL: special-complexes
[ 
    { -1 0 1 i -i } %
    e , e neg , pi , pi neg ,
    0 pi rect> , 0 pi neg rect> , pi neg 0 rect> , pi pi rect> ,
    pi pi neg rect> , pi neg pi rect> , pi neg pi neg rect> ,
    e neg e neg rect> , e e rect> ,
] { } make \ special-complexes set
: special-complexes ( -- seq ) \ special-complexes get ;

: random-fixnum ( -- fixnum )
    most-positive-fixnum random-int 1+ coin-flip [ neg 1- ] when >fixnum ;

: random-bignum ( -- bignum )
     400 random-bits first-bignum + coin-flip [ neg ] when ;
    
: random-integer
    coin-flip [
            random-fixnum
        ] [
            coin-flip [ random-bignum ] [ special-integers nth-rand ] if
        ] if ;

: random-positive-integer ( -- int )
    random-integer dup 0 < [
            neg
        ] [
            dup 0 = [ 1 + ] when
    ] if ;

: random-ratio ( -- ratio )
    1000000000 dup [ random-int ] 2apply 1+ / coin-flip [ neg ] when dup [ drop random-ratio ] unless 10% [ drop 0 ] when ;

: random-float ( -- float )
    coin-flip [ random-ratio ] [ special-floats nth-rand ] if
    coin-flip 
    [ .0000000000000000001 /f ] [ coin-flip [ .00000000000000001 * ] when ] if
    >float ;

: random-number ( -- number )
    {
        [ random-integer ]
        [ random-ratio ]
        [ random-float ]
    } do-one ;

: random-complex ( -- C{ } )
    random-number random-number rect> ;

