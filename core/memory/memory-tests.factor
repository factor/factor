USING: generic kernel kernel.private math memory prettyprint
sequences tools.test words namespaces layouts classes
classes.builtin ;
IN: memory.tests

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
