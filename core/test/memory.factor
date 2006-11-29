IN: temporary
USING: generic kernel kernel-internals math memory prettyprint
sequences test words ;

TUPLE: testing x y z ;

[ ] [
    num-types [
        type>class [
            "predicate" word-prop instances [
                class drop
            ] each
        ] when*
    ] each
] unit-test
