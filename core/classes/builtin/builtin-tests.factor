USING: tools.test words sequences kernel memory accessors ;
IN: classes.builtin.tests

[ f ] [
    [ word? ] instances
    [
        [ name>> "f?" = ]
        [ vocabulary>> "syntax" = ] bi and
    ] any?
] unit-test
