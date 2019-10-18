USING: accessors compiler.tree kernel tools.test ;
IN: compiler.tree.tests

{
    "label"
    "a-child"
} [
    "label" f "a-child" <#recursive>
    [ label>> ] [ child>> ] bi
] unit-test
