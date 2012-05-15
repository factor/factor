
USING: assocs.extras tools.test ;

IN: assocs.extras

{ f } [ H{ } { 1 2 3 } deep-at ] unit-test
{ 4 } [ H{ { 1 H{ { 2 H{ { 3 4 } } } } } } { 1 2 3 } deep-at ] unit-test
