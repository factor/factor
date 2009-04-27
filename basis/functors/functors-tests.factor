IN: functors.tests
USING: functors tools.test math words kernel multiline parser
io.streams.string generic ;

<<

FUNCTOR: define-box ( T -- )

B DEFINES-CLASS ${T}-box
<B> DEFINES <${B}>

WHERE

TUPLE: B { value T } ;

C: <B> B ( T -- B )

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

<<

FUNCTOR: symbol-test ( W -- )

W DEFINES ${W}

WHERE

SYMBOL: W

;FUNCTOR

"blorgh" symbol-test

>>

[ blorgh ] [ blorgh ] unit-test

GENERIC: some-generic ( a -- b )

! Does replacing an ordinary word with a functor-generated one work?
[ [ ] ] [
    <" IN: functors.tests

    TUPLE: some-tuple ;
    : some-word ( -- ) ;
    M: some-tuple some-generic ;
    SYMBOL: some-symbol
    "> <string-reader> "functors-test" parse-stream
] unit-test

: test-redefinition ( -- )
    [ t ] [ "some-word" "functors.tests" lookup >boolean ] unit-test
    [ t ] [ "some-tuple" "functors.tests" lookup >boolean ] unit-test
    [ t ] [
        "some-tuple" "functors.tests" lookup
        "some-generic" "functors.tests" lookup method >boolean
    ] unit-test ;
    [ t ] [ "some-symbol" "functors.tests" lookup >boolean ] unit-test

test-redefinition

FUNCTOR: redefine-test ( W -- )

W-word DEFINES ${W}-word
W-tuple DEFINES-CLASS ${W}-tuple
W-generic IS ${W}-generic
W-symbol DEFINES ${W}-symbol

WHERE

TUPLE: W-tuple ;
: W-word ( -- ) ;
M: W-tuple W-generic ;
SYMBOL: W-symbol

;FUNCTOR

[ [ ] ] [
    <" IN: functors.tests
    << "some" redefine-test >>
    "> <string-reader> "functors-test" parse-stream
] unit-test

test-redefinition

