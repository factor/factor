USING: arrays assocs classes.tuple kernel math named-tuples
sequences tools.test ;
IN: named-tuples.tests

TUPLE: foo x y z ;

INSTANCE: foo named-tuple

{ { f f f } } [ T{ foo } >array ] unit-test
{ { 1 f f } } [ T{ foo f 1 } >array ] unit-test
{ { 1 2 f } } [ T{ foo f 1 2 } >array ] unit-test
{ { 1 2 3 } } [ T{ foo f 1 2 3 } >array ] unit-test

{ T{ foo } } [ { } T{ foo } like ] unit-test
{ T{ foo f 1 } } [ { 1 } T{ foo } like ] unit-test
{ T{ foo f 1 2 } } [ { 1 2 } T{ foo } like ] unit-test
{ T{ foo f 1 2 3 } } [ { 1 2 3 } T{ foo } like ] unit-test

{ { { "x" f } { "y" f } { "z" f } } } [ T{ foo } >alist ] unit-test
{ { { "x" 1 } { "y" f } { "z" f } } } [ T{ foo f 1 } >alist ] unit-test
{ { { "x" 1 } { "y" 2 } { "z" f } } } [ T{ foo f 1 2 } >alist ] unit-test
{ { { "x" 1 } { "y" 2 } { "z" 3 } } } [ T{ foo f 1 2 3 } >alist ] unit-test

{ f } [ T{ foo } "x" of ] unit-test
{ f } [ T{ foo } "y" of ] unit-test
{ f } [ T{ foo } "z" of ] unit-test

{ f f } [ "not found" T{ foo f 1 2 3 } at* ] unit-test

{ T{ foo f "x" 2 3 } } [ T{ foo f 1 2 3 } "x" dup pick set-at ] unit-test

[ 1 "not found" T{ foo f 1 2 3 } set-at ] [ no-slot? ] must-fail-with

{ 1 } [ T{ foo f 1 2 3 } "x" of ] unit-test
{ 2 } [ T{ foo f 1 2 3 } "y" of ] unit-test
{ 3 } [ T{ foo f 1 2 3 } "z" of ] unit-test

{ 1 } [ 0 >bignum T{ foo f 1 2 3 } nth ] unit-test
{ 2 } [ 1 >bignum T{ foo f 1 2 3 } nth ] unit-test
{ 3 } [ 2 >bignum T{ foo f 1 2 3 } nth ] unit-test
