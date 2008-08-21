USING: kernel tools.test sequences vectors assocs.lib ;
IN: assocs.lib.tests

{ 1 1 } [ [ ?push ] histogram ] must-infer-as

! substitute
[ { 2 } ] [ { 1 } H{ { 1 2 } } [ ?at drop ] curry map ] unit-test
[ { 3 } ] [ { 3 } H{ { 1 2 } } [ ?at drop ] curry map ] unit-test

[ 2 ] [ 1 H{ { 1 2 } } [ ] [ ] if-at ] unit-test
[ 3 ] [ 3 H{ { 1 2 } } [ ] [ ] if-at ] unit-test

[ "hi" ] [ 1 H{ { 1 2 } } [ drop "hi" ] when-at ] unit-test
[ 3 ] [ 3 H{ { 1 2 } } [ drop "hi" ] when-at ] unit-test
[ 2 ] [ 1 H{ { 1 2 } } [ drop "hi" ] unless-at ] unit-test
[ "hi" ] [ 3 H{ { 1 2 } } [ drop "hi" ] unless-at ] unit-test

