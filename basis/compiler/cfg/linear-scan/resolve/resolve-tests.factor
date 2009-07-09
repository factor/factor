USING: arrays compiler.cfg.linear-scan.resolve kernel
tools.test ;
IN: compiler.cfg.linear-scan.resolve.tests

[ { 1 2 3 4 5 6 } ] [
    { 3 4 } V{ 1 2 } clone [ { 5 6 } 3append-here ] keep >array
] unit-test
