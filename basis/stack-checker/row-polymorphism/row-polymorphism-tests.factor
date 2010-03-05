! (c)2010 Joe Groff bsd license
USING: effects fry io kernel math namespaces sequences
system tools.test
stack-checker.backend
stack-checker.errors
stack-checker.row-polymorphism
stack-checker.state
stack-checker.values ;
IN: stack-checker.row-polymorphism.tests

[ 3 f   ] [ (( a b c -- d )) in-effect-variable ] unit-test
[ 0 f   ] [ (( -- d )) in-effect-variable ] unit-test
[ 2 "a" ] [ (( ..a b c -- d )) in-effect-variable ] unit-test
[ (( a ..b c -- d )) in-effect-variable ] [ invalid-effect-variable? ] must-fail-with
[ (( ..a: integer b c -- d )) in-effect-variable ] [ effect-variable-can't-have-type? ] must-fail-with

: checked-each ( ..a seq quot: ( ..a x -- ..a ) -- ..a )
    curry call ; inline

: checked-map ( ..a seq quot: ( ..a x -- ..a y ) -- ..a seq' )
    curry call f ; inline

: checked-map-index ( ..a seq quot: ( ..a x index -- ..a y ) -- ..a seq' )
    0 swap 2curry call f ; inline

: checked-if ( ..a x then: ( ..a -- ..b ) else: ( ..a -- ..b ) -- ..b )
    drop nip call ; inline

: checked-if* ( ..a x then: ( ..a x -- ..b ) else: ( ..a -- ..b ) -- ..b )
    drop call ; inline

: checked-with-variable ( ..a value key quot: ( ..a -- ..b ) -- ..b )
    2nip call ; inline

: infer-polymorphic-quot ( quot -- vars )
    t infer-polymorphic? [
        unclip-last [
            dup current-word set
            init-inference
            init-known-values
            [ [ <literal> <value> [ set-known ] [ push-d ] bi ] each ]
            [ stack-effect ] bi*
            infer-polymorphic-vars
        ] with-scope
    ] with-variable ;

: test-poly-infer ( effect quot -- )
    [ '[ _ ] ] [ '[ _ infer-polymorphic-quot ] ] bi* unit-test ; inline

: poly-infer-must-fail ( quot -- )
    '[ _ infer-polymorphic-quot ] [ invalid-quotation-input? ] must-fail-with ; inline
: poly-infer-must-fail-bad-macro-input ( quot -- )
    '[ _ infer-polymorphic-quot ] [ bad-macro-input? ] must-fail-with ; inline

H{ { "a" 0 } } [ [ write      ] checked-each ] test-poly-infer
H{ { "a" 1 } } [ [ append     ] checked-each ] test-poly-infer
H{ { "a" 0 } } [ [            ] checked-map  ] test-poly-infer
H{ { "a" 0 } } [ [ reverse    ] checked-map  ] test-poly-infer
H{ { "a" 1 } } [ [ append dup ] checked-map  ] test-poly-infer
H{ { "a" 1 } } [ [ swap nth suffix dup ] checked-map-index ] test-poly-infer

H{ { "a" 3 } { "b" 1 } } [ [ 2drop ] [ 2nip    ] checked-if ] test-poly-infer
H{ { "a" 2 } { "b" 3 } } [ [ dup   ] [ over    ] checked-if ] test-poly-infer
H{ { "a" 0 } { "b" 1 } } [ [ os    ] [ cpu     ] checked-if ] test-poly-infer
H{ { "a" 1 } { "b" 2 } } [ [ os    ] [ 1 + cpu ] checked-if ] test-poly-infer

H{ { "a" 0 } { "b" 0 } } [ [ write     ] [ "(f)" write ] checked-if* ] test-poly-infer
H{ { "a" 0 } { "b" 1 } } [ [           ] [ f           ] checked-if* ] test-poly-infer
H{ { "a" 1 } { "b" 1 } } [ [ nip       ] [ drop f      ] checked-if* ] test-poly-infer
H{ { "a" 1 } { "b" 1 } } [ [ nip       ] [             ] checked-if* ] test-poly-infer
H{ { "a" 2 } { "b" 2 } } [ [ 3append f ] [             ] checked-if* ] test-poly-infer
H{ { "a" 0 } { "b" 0 } } [ [ drop      ] [             ] checked-if* ] test-poly-infer

H{ { "a" 1 } { "b" 0 } } [ [ write ] checked-with-variable ] test-poly-infer
H{ { "a" 0 } { "b" 1 } } [ [ os    ] checked-with-variable ] test-poly-infer
H{ { "a" 1 } { "b" 1 } } [ [ dup + ] checked-with-variable ] test-poly-infer

[ [ write write ] checked-each      ] poly-infer-must-fail
[ [             ] checked-each      ] poly-infer-must-fail
[ [ dup         ] checked-map       ] poly-infer-must-fail
[ [ drop        ] checked-map       ] poly-infer-must-fail
[ [ 1 +         ] checked-map-index ] poly-infer-must-fail

[ [ dup  ] [      ] checked-if ] poly-infer-must-fail
[ [ 2dup ] [ over ] checked-if ] poly-infer-must-fail
[ [ drop ] [      ] checked-if ] poly-infer-must-fail

[ [      ] [       ] checked-if* ] poly-infer-must-fail
[ [ dup  ] [       ] checked-if* ] poly-infer-must-fail
[ [ drop ] [ drop  ] checked-if* ] poly-infer-must-fail
[ [      ] [ drop  ] checked-if* ] poly-infer-must-fail
[ [      ] [ 2dup  ] checked-if* ] poly-infer-must-fail

[ "derp" checked-each ] poly-infer-must-fail
[ checked-each ] poly-infer-must-fail-bad-macro-input
[ "derp" [ "derp" ] checked-if ] poly-infer-must-fail
[ [ "derp" ] "derp" checked-if ] poly-infer-must-fail
[ [ "derp" ] checked-if ] poly-infer-must-fail-bad-macro-input

