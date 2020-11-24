USING: compression.gzip tools.test ;

{ V{ { 0 0 0 } } } [ B{ 0 } compress-lz77 ] unit-test
{ V{ { 0 0 0 } { 0 0 1 } { 2 2 1 } } } [ B{ 0 1 0 1 1 } compress-lz77 ] unit-test

