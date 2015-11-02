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
        [
            stack-frame>>
            [ spill-area-size>> ]
            [ spill-area-align>> cell = ] bi
        ]
    } cleave
] unit-test
