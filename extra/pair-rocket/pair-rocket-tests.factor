! (c)2009 Joe Groff bsd license
USING: kernel pair-rocket tools.test ;
IN: pair-rocket.tests

[ { "a" 1 } ] [ "a" => 1 ] unit-test
[ { { "a" } { 1 } } ] [ { "a" } => { 1 } ] unit-test
[ { drop 1 } ] [ drop => 1 ] unit-test

[ H{ { "zippity" 5 } { "doo" 2 } { "dah" 7 } } ]
[ H{ "zippity" => 5 "doo" => 2 "dah" => 7 } ] unit-test
