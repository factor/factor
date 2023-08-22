! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel pair-rocket tools.test ;

{ { "a" 1 } } [ "a" => 1 ] unit-test
{ { { "a" } { 1 } } } [ { "a" } => { 1 } ] unit-test
{ { drop 1 } } [ drop => 1 ] unit-test

{ H{ { "zippity" 5 } { "doo" 2 } { "dah" 7 } } }
[ H{ "zippity" => 5 "doo" => 2 "dah" => 7 } ] unit-test
