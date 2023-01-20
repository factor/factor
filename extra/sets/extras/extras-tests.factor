! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: math sequences sets.extras tools.test ;

{ { } } [ { } { } setwise-xor ] unit-test
{ { 1 } } [ { 1 } { } setwise-xor ] unit-test
{ { 1 } } [ { } { 1 } setwise-xor ] unit-test
{ { } } [ { 1 } { 1 } setwise-xor ] unit-test
{ { 1 4 5 7 } } [ { 1 2 3 2 4 } { 2 3 5 7 5 } setwise-xor ] unit-test

{ { } } [ { } { } symmetric-diff ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } { } symmetric-diff ] unit-test
{ { 1 2 3 } } [ { } { 1 2 3 } symmetric-diff ] unit-test
{ { 1 2 4 5 } } [ { 1 2 3 } { 3 4 5 } symmetric-diff ] unit-test

{ f } [ { } { } proper-subset? ] unit-test
{ f } [ { 1 2 } { 1 2 } proper-subset? ] unit-test
{ f } [ { 1 2 3 } { 1 2 } proper-subset? ] unit-test
{ t } [ { 1 2 } { 1 2 3 } proper-subset? ] unit-test

{ "abc" } [ "abc" non-repeating ] unit-test
{ "abc" } [ "abcddd" non-repeating ] unit-test
{ "" } [ "aabbcc" non-repeating ] unit-test

{ HS{ 0 10 20 30 40 } } [ 5 <iota> [ 10 * ] mapped-set ] unit-test

{ { 1 2 4 } } [ { 1 2 3 4 5 } [ 2/ ] unique-by ] unit-test
