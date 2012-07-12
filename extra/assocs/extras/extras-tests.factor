
USING: assocs.extras tools.test ;

IN: assocs.extras

{ f } [ f { } deep-at ] unit-test
{ f } [ f { "foo" } deep-at ] unit-test
{ f } [ H{ } { 1 2 3 } deep-at ] unit-test
{ f } [ H{ { "a" H{ { "b" 1 } } } } { "a" "c" } deep-at ] unit-test
{ 1 } [ H{ { "a" H{ { "b" 1 } } } } { "a" "b" } deep-at ] unit-test
{ 4 } [ H{ { 1 H{ { 2 H{ { 3 4 } } } } } } { 1 2 3 } deep-at ] unit-test

{  { { 1 3 } { 2 4 } } } [ { 1 2 } { 3 4 }  { } zip-as ] unit-test
{ V{ { 1 3 } { 2 4 } } } [ { 1 2 } { 3 4 } V{ } zip-as ] unit-test
{ H{ { 1 3 } { 2 4 } } } [ { 1 2 } { 3 4 } H{ } zip-as ] unit-test
