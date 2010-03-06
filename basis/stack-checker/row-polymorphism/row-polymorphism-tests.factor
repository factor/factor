! (c)2010 Joe Groff bsd license
USING: effects fry io kernel math namespaces sequences
system tools.test
stack-checker.backend
stack-checker.errors
stack-checker.row-polymorphism
stack-checker.state
stack-checker.values ;
IN: stack-checker.row-polymorphism.tests

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
: poly-infer-must-fail-unknown ( quot -- )
    '[ _ infer-polymorphic-quot ] [ unknown-macro-input? ] must-fail-with ; inline

H{ { "." 0 } } [ [ write      ] each ] test-poly-infer
H{ { "." 1 } } [ [ append     ] each ] test-poly-infer
H{ { "." 0 } } [ [            ] map  ] test-poly-infer
H{ { "." 0 } } [ [ reverse    ] map  ] test-poly-infer
H{ { "." 1 } } [ [ append dup ] map  ] test-poly-infer
H{ { "." 1 } } [ [ swap nth suffix dup ] map-index ] test-poly-infer

H{ { "a" 3 } { "b" 1 } } [ [ 2drop ] [ 2nip    ] if ] test-poly-infer
H{ { "a" 2 } { "b" 3 } } [ [ dup   ] [ over    ] if ] test-poly-infer
H{ { "a" 0 } { "b" 1 } } [ [ os    ] [ cpu     ] if ] test-poly-infer
H{ { "a" 1 } { "b" 2 } } [ [ os    ] [ 1 + cpu ] if ] test-poly-infer

H{ { "a" 0 } { "b" 0 } } [ [ write     ] [ "(f)" write ] if* ] test-poly-infer
H{ { "a" 0 } { "b" 1 } } [ [           ] [ f           ] if* ] test-poly-infer
H{ { "a" 1 } { "b" 1 } } [ [ nip       ] [ drop f      ] if* ] test-poly-infer
H{ { "a" 1 } { "b" 1 } } [ [ nip       ] [             ] if* ] test-poly-infer
H{ { "a" 2 } { "b" 2 } } [ [ 3append f ] [             ] if* ] test-poly-infer
H{ { "a" 0 } { "b" 0 } } [ [ drop      ] [             ] if* ] test-poly-infer

H{ { "a" 0 } { "b" 1 } } [ [ 1 +       ] [ "oops" throw ] if* ] test-poly-infer

[ [ write write ] each      ] poly-infer-must-fail
[ [             ] each      ] poly-infer-must-fail
[ [ dup         ] map       ] poly-infer-must-fail
[ [ drop        ] map       ] poly-infer-must-fail
[ [ 1 +         ] map-index ] poly-infer-must-fail

[ [ dup  ] [      ] if ] poly-infer-must-fail
[ [ 2dup ] [ over ] if ] poly-infer-must-fail
[ [ drop ] [      ] if ] poly-infer-must-fail

[ [      ] [       ] if* ] poly-infer-must-fail
[ [ dup  ] [       ] if* ] poly-infer-must-fail
[ [ drop ] [ drop  ] if* ] poly-infer-must-fail
[ [      ] [ drop  ] if* ] poly-infer-must-fail
[ [      ] [ 2dup  ] if* ] poly-infer-must-fail

[ each ] poly-infer-must-fail-unknown
[ [ "derp" ] if ] poly-infer-must-fail-unknown

