USING: compiler.utilities kernel tools.test ;
IN: compiler.utilities.tests

{
    9
    H{ { 9 9 } { 44 9 } { 7 9 } }
} [
    7 H{ { 7 44 } { 44 9 } { 9 9 } } [ compress-path ] keep
] unit-test
