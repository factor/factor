USING: generic kernel kernel.private math memory prettyprint
sequences tools.test words namespaces layouts classes
classes.builtin arrays quotations ;
IN: memory.tests

! Code GC wasn't kicking in when needed
: leak-step 800000 f <array> 1quotation call drop ;

: leak-loop 100 [ leak-step ] times ;

[ ] [ leak-step leak-step leak-step data-gc ] unit-test

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
