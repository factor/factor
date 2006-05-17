IN: temporary
USING: generic kernel math memory words prettyprint 
sequences test ;

TUPLE: testing x y z ;

[ f 1 2 3 ] [ 1 2 3 <testing> [ ] each-slot ] unit-test

[ ] [
    num-types [
        type>class [
            "predicate" word-prop instances [
                class drop
            ] each
        ] when*
    ] each
] unit-test
