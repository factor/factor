USING: accessors assocs combinators compiler.cfg compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.height kernel tools.test ;
IN: compiler.cfg.stacks.height.tests

{
    T{ ds-loc f 4 }
    T{ rs-loc f 5 }
} [
    begin-stack-analysis
    3 4 T{ basic-block }
    [ record-stack-heights ]
    [ D 1 swap untranslate-loc ]
    [ R 1 swap untranslate-loc ] tri
] unit-test
