IN: compiler.cfg.linear-scan.resolve.tests
USING: compiler.cfg.linear-scan.resolve tools.test arrays kernel ;

[ { 1 2 3 4 5 6 } ] [
    { 3 4 } V{ 1 2 } clone [ { 5 6 } 3append-here ] keep >array
] unit-test