USING: xmode.rules tools.test ;

{ { 1 2 3 } } [ f { 1 2 3 } ?push-all ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } f ?push-all ] unit-test
{ V{ 1 2 3 4 5 } } [ { 1 2 3 } { 4 5 } ?push-all ] unit-test
