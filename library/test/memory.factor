IN: temporary
USING: generic kernel lists math memory words ;

num-types [
    [
        builtin-type [
            "predicate" word-prop instances [
                class drop
            ] each
        ] when*
    ] keep
] repeat
