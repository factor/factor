USING: generic kernel kernel.private math memory prettyprint
sequences tools.test words namespaces layouts classes
classes.builtin arrays quotations ;
IN: memory.tests

[ [ ] instances ] must-infer

! Code GC wasn't kicking in when needed
: leak-step 800000 f <array> 1quotation call drop ;

: leak-loop 100 [ leak-step ] times ;

[ ] [ leak-loop ] unit-test

TUPLE: testing x y z ;

[ save-image-and-exit ] must-fail

[ ] [
    num-types get [
        type>class [
            "predicate" word-prop instances [
                class drop
            ] each
        ] when*
    ] each
] unit-test

! Erg's bug
2 [ [ [ 3 throw ] instances ] must-fail ] times
