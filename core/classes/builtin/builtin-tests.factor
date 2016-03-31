USING: accessors kernel memory sequences tools.test words ;
IN: classes.builtin.tests

{ f } [
    [ word? ] instances
    [
        [ name>> "f?" = ]
        [ vocabulary>> "syntax" = ] bi and
    ] any?
] unit-test
