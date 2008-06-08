IN: inference.transforms.tests
USING: sequences inference.transforms tools.test math kernel
quotations inference accessors combinators words arrays
classes ;

: compose-n-quot ( word -- quot' ) <repetition> >quotation ;
: compose-n ( quot -- ) compose-n-quot call ;
\ compose-n [ compose-n-quot ] 2 define-transform
: compose-n-test ( -- x ) 2 \ + compose-n ;

[ 6 ] [ 1 2 3 compose-n-test ] unit-test

[ 0 ] [ { } bitfield-quot call ] unit-test

[ 256 ] [ 1 { 8 } bitfield-quot call ] unit-test

[ 268 ] [ 3 1 { 8 2 } bitfield-quot call ] unit-test

[ 268 ] [ 1 { 8 { 3 2 } } bitfield-quot call ] unit-test

[ 512 ] [ 1 { { 1+ 8 } } bitfield-quot call ] unit-test

TUPLE: color r g b ;

C: <color> color

: cleave-test ( color -- r g b )
    { [ r>> ] [ g>> ] [ b>> ] } cleave ;

{ 1 3 } [ cleave-test ] must-infer-as

[ 1 2 3 ] [ 1 2 3 <color> cleave-test ] unit-test

[ 1 2 3 ] [ 1 2 3 <color> \ cleave-test word-def call ] unit-test

: 2cleave-test ( a b -- c d e ) { [ 2array ] [ + ] [ - ] } 2cleave ;

[ { 1 2 } 3 -1 ] [ 1 2 2cleave-test ] unit-test

[ { 1 2 } 3 -1 ] [ 1 2 \ 2cleave-test word-def call ] unit-test

: spread-test ( a b c -- d e f ) { [ sq ] [ neg ] [ recip ] } spread ;

[ 16 -3 1/6 ] [ 4 3 6 spread-test ] unit-test

[ 16 -3 1/6 ] [ 4 3 6 \ spread-test word-def call ] unit-test

[ fixnum instance? ] must-infer
