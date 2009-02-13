USING: assocs xmode.utilities tools.test ;
IN: xmode.utilities.tests

[ "hi" 3 ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 3 "hi" } } at ] map-find
] unit-test

[ f f ] [
    { 1 2 3 4 5 6 7 8 } [ H{ { 11 "hi" } } at ] map-find
] unit-test
