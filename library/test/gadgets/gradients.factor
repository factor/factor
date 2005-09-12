IN: temporary
USING: gadgets namespaces styles test ;

[ @{ 255 0 0 }@ ] [ @{ 1 0 0 }@ red green <gradient> 0 gradient-color ] unit-test
[ @{ 0 255 0 }@ ] [ @{ 1 0 0 }@ red green <gradient> 1 gradient-color ] unit-test

[ 0 100 0 @{ 255 0 0 }@ ]
[ @{ 0 1 0 }@ red green <gradient> @{ 100 200 0 }@ 0 (gradient-x) ] unit-test

[ 0 100 100 @{ 255/2 255/2 0 }@ ]
[ @{ 0 1 0 }@ red green <gradient> @{ 100 200 0 }@ 100 (gradient-x) ] unit-test

[ 0 0 200 @{ 255 0 0 }@ ]
[ @{ 1 0 0 }@ red green <gradient> @{ 100 200 0 }@ 0 (gradient-y) ] unit-test

[ 50 0 200 @{ 255/2 255/2 0 }@ ]
[ @{ 1 0 0 }@ red green <gradient> @{ 100 200 0 }@ 50 (gradient-y) ] unit-test
