USING: accessors arrays assocs combinators compiler.cfg.registers
compiler.cfg.stacks.local kernel literals namespaces tools.test ;
IN: compiler.cfg.stacks

{ H{ { D -2 4 } { D -1 3 } { D -3 5 } } } [
    {
        ${ current-height current-height new }
        ${ replace-mapping H{ } clone }
    } [
        { 3 4 5 } ds-store replace-mapping get
    ] with-variables
] unit-test
