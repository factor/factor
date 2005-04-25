IN: temporary
USING: generic kernel lists math memory words prettyprint test ;

[ ] [
    num-types [
        [
            builtin-type [
                "predicate" word-prop instances [
                    class drop
                ] each
            ] when*
        ] keep
    ] repeat
] unit-test
