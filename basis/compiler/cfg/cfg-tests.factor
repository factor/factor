USING: accessors compiler.cfg kernel tools.test ;
IN: compiler.cfg.tests

{
    "word"
    "label"
} [
    "word" "label" <basic-block> <cfg>
    [ word>> ] [ label>> ] bi
] unit-test
