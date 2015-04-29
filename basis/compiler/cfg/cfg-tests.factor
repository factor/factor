USING: accessors combinators compiler.cfg kernel layouts tools.test ;
IN: compiler.cfg.tests

{
    "word"
    "label"
    0
    t
} [
    "word" "label" <basic-block> <cfg>
    {
        [ word>> ]
        [ label>> ]
        [ spill-area-size>> ]
        [ spill-area-align>> cell = ]
    } cleave
] unit-test
