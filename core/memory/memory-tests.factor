USING: generic kernel kernel.private math memory prettyprint
sequences tools.test words namespaces layouts classes ;
IN: temporary

TUPLE: testing x y z ;

[ save-image-and-exit ] unit-test-fails

[ ] [
    num-types get [
        type>class [
            "predicate" word-prop instances [
                class drop
            ] each
        ] when*
    ] each
] unit-test
