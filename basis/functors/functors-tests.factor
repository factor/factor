IN: functors.tests
USING: functors tools.test math words kernel ;

<<

FUNCTOR: define-box ( T -- )

B DEFINES ${T}-box
<B> DEFINES <${B}>

WHERE

TUPLE: B { value T } ;

C: <B> B

;FUNCTOR

\ float define-box

>>

{ 1 0 } [ define-box ] must-infer-as

[ T{ float-box f 5.0 } ] [ 5.0 <float-box> ] unit-test

: twice ( word -- )
    [ execute ] [ execute ] bi ; inline
<<

FUNCTOR: wrapper-test ( W -- )

WW DEFINES ${W}${W}

WHERE

: WW ( a -- b ) \ W twice ; inline

;FUNCTOR

\ sq wrapper-test

>>

\ sqsq must-infer

[ 16 ] [ 2 sqsq ] unit-test

<<

FUNCTOR: wrapper-test-2 ( W -- )

W DEFINES ${W}

WHERE

: W ( a b -- c ) \ + execute ;

;FUNCTOR

"blah" wrapper-test-2

>>

[ 4 ] [ 1 3 blah ] unit-test