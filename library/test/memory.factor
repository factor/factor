IN: scratchpad
USING: generic kernel lists math memory words ;

num-types [
    [
        builtin-type [
            "predicate" word-property instances [
                class drop
            ] each
        ] when*
    ] keep
] repeat
