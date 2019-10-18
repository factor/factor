USING: generic.parser tools.test ;

{ t } [ ( -- ) ( -- ) method-effect= ] unit-test
{ t } [ ( a -- b ) ( x -- y ) method-effect= ] unit-test
{ f } [ ( a b -- c ) ( x -- y ) method-effect= ] unit-test
{ f } [ ( a -- b ) ( x y -- z ) method-effect= ] unit-test

{ t } [ ( -- * ) ( -- ) method-effect= ] unit-test
{ f } [ ( -- * ) ( x -- y ) method-effect= ] unit-test
{ t } [ ( x -- * ) ( x -- y ) method-effect= ] unit-test
{ t } [ ( x -- * ) ( x -- y z ) method-effect= ] unit-test
