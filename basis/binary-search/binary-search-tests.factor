USING: binary-search kernel math.order sequences tools.test ;

{ f } [ 3 { } [ <=> ] with search drop ] unit-test
{ 0 } [ 3 { 3 } [ <=> ] with search drop ] unit-test
{ 1 } [ 2 { 1 2 3 } [ <=> ] with search drop ] unit-test
{ 3 } [ 4 { 1 2 3 4 5 6 } [ <=> ] with search drop ] unit-test
{ 2 } [ 3.5 { 1 2 3 4 5 6 7 8 } [ <=> ] with search drop ] unit-test
{ 4 } [ 5.5 { 1 2 3 4 5 6 7 8 } [ <=> ] with search drop ] unit-test
{ 10 } [ 10 20 <iota> [ <=> ] with search drop ] unit-test

{ 0 } [ "alligator" { "alligator" "cat" "fish" "hello" "ikarus" "java" } sorted-index ] unit-test
{ 3 } [ "hey" { "alligator" "cat" "fish" "hello" "ikarus" "java" } sorted-index ] unit-test
{ 5 } [ "java" { "alligator" "cat" "fish" "hello" "ikarus" "java" } sorted-index ] unit-test
{ t } [ "hello" { "alligator" "cat" "fish" "hello" "ikarus" "java" } sorted-member? ] unit-test
{ f } [ "hello" { "alligator" "cat" "fish" "ikarus" "java" } sorted-member? ] unit-test
{ f } [ "zebra" { "alligator" "cat" "fish" "ikarus" "java" } sorted-member? ] unit-test
