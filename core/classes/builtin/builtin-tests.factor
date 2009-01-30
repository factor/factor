IN: classes.builtin.tests
USING: tools.test words sequences kernel memory accessors ;

[ f ] [
    [ word? ] instances
    [
        [ name>> "f?" = ]
        [ vocabulary>> "syntax" = ] bi and
    ] any?
] unit-test
