IN: temporary
USING: generic kernel kernel-internals math memory prettyprint
sequences test words namespaces ;

TUPLE: testing x y z ;

[ ] [
    num-types get [
        type>class [
            "predicate" word-prop instances [
                class drop
            ] each
        ] when*
    ] each
] unit-test

[ ] [ heap-stats. ] unit-test
