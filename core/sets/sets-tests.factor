! Copyright (C) 2010 Daniel Ehrenberg, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: bit-arrays bit-sets kernel math sequences sets sorting
tools.test ;
IN: sets.tests

{ V{ 1 2 3 } } [ 3 V{ 1 2 } clone [ adjoin ] keep ] unit-test
{ V{ 1 2 } } [ 2 V{ 1 2 } clone [ adjoin ] keep ] unit-test
{ t } [ 1 V{ } ?adjoin ] unit-test
{ f } [ 1 V{ 1 } ?adjoin ] unit-test

{ t } [ 4 { 2 4 5 } in? ] unit-test
{ f } [ 1 { 2 4 5 } in? ] unit-test
{ f } [ f 5 <bit-set> in? ] unit-test

{ V{ 1 2 } } [ 3 V{ 1 2 } clone [ delete ] keep ] unit-test
{ V{ 2 } } [ 1 V{ 1 2 } clone [ delete ] keep ] unit-test
{ t } [ 1 V{ 1 } ?delete ] unit-test
{ f } [ 1 V{ } ?delete ] unit-test
{ 0 } [ 5 <bit-set> 0 over delete cardinality ] unit-test
{ 0 } [ 5 <bit-set> f over delete cardinality ] unit-test
{ 0 } [ 5 <bit-set> 3 over adjoin 3 over delete cardinality ] unit-test
{ 0 } [ 5 <bit-set> 10 over delete cardinality ] unit-test
{ HS{ 1 } } [ HS{ 1 2 } 2 over delete ] unit-test

{ { 1 2 3 } } [ { 1 1 1 2 2 3 3 3 3 3 } dup set-like sort ] unit-test
{ { 1 2 3 } } [ HS{ 1 2 3 } { } set-like sort ] unit-test
{ { 1 2 3 } } [ { 1 2 2 3 3 } { } set-like ] unit-test
{ { 3 2 1 } } [ { 3 3 2 2 1 } { } set-like ] unit-test
{ t } [ 4 <bit-set> 1 <bit-set> set-like 4 <bit-set> = ] unit-test
{ t } [ { 1 2 3 } HS{ } set-like HS{ 1 2 3 } = ] unit-test

{ HS{ 1 2 3 } } [ { 1 2 3 } fast-set ] unit-test
{ T{ bit-set { table ?{ f } } } }
[ 1 <bit-set> fast-set ] unit-test

{ { 1 } } [ { 1 } members ] unit-test

{ { } } [ { } { } union ] unit-test
{ { 1 2 3 4 } } [ { 1 2 3 } { 2 3 4 } union ] unit-test

{ { } } [ { } { } intersect ] unit-test
{ { 2 3 } } [ { 1 2 3 } { 2 3 4 } intersect ] unit-test
{ { 2 3 } } [ { 1 2 3 } { 2 3 4 5 } intersect ] unit-test
{ { 2 3 4 } } [ { 1 2 3 4 } { 2 3 4 } intersect ] unit-test
{ { 2 3 } } [ { 1 2 2 3 } { 2 3 3 4 } intersect ] unit-test

{ t } [ { 1 2 } { 1 3 } intersects? ] unit-test
{ f } [ { 4 2 } { 1 3 } intersects? ] unit-test
{ f } [ { } { 1 } intersects? ] unit-test
{ f } [ { 1 } { } intersects? ] unit-test
{ f } [ { } { } intersects? ] unit-test

{ { } } [ { } { } diff ] unit-test
{ { 1 } } [ { 1 2 3 } { 2 3 4 } diff ] unit-test
{ { 1 } } [ { 1 2 3 } { 2 3 4 5 } diff ] unit-test
{ { 1 } } [ { 1 2 3 4 } { 2 3 4 } diff ] unit-test
{ { 1 } } [ { 1 1 2 3 } { 2 3 4 4 } diff ] unit-test

{ T{ bit-set { table ?{ f f f } } } }
[ 3 <bit-set> 0 over adjoin dup diff ] unit-test

{ f } [ { 1 2 3 4 } { 1 2 } subset? ] unit-test
{ t } [ { 1 2 3 4 } { 1 2 } swap subset? ] unit-test
{ t } [ { 1 2 } { 1 2 } subset? ] unit-test
{ t } [ { } { 1 2 } subset? ] unit-test
{ t } [ { } { } subset? ] unit-test
{ f } [ { 1 } { } subset? ] unit-test

{ t } [ { 1 2 3 } { 2 1 3 } set= ] unit-test
{ f } [ { 2 3 } { 1 2 3 } set= ] unit-test
{ f } [ { 1 2 3 } { 2 3 } set= ] unit-test

{ { 2 1 2 1 } } [ { 1 2 3 2 1 2 1 } duplicates ] unit-test
{ f } [ HS{ 1 2 3 1 2 1 } duplicates ] unit-test

{ f } [ { 0 1 1 2 3 5 } all-unique? ] unit-test
{ t } [ { 0 1 2 3 4 5 } all-unique? ] unit-test
{ t } [ HS{ 0 1 2 3 4 5 } all-unique? ] unit-test

{ t } [ f null? ] unit-test
{ f } [ { 4 } null? ] unit-test
{ t } [ HS{ } null? ] unit-test
{ f } [ HS{ 3 } null? ] unit-test
{ t } [ 2 <bit-set> null? ] unit-test
{ f } [ 3 <bit-set> 0 over adjoin null? ] unit-test

{ 0 } [ f cardinality ] unit-test
{ 0 } [ { } cardinality ] unit-test
{ 1 } [ { 1 } cardinality ] unit-test
{ 1 } [ { 1 1 } cardinality ] unit-test
{ 1 } [ HS{ 1 } cardinality ] unit-test
{ 3 } [ HS{ 1 2 3 } cardinality ] unit-test
{ 0 } [ 0 <bit-set> cardinality ] unit-test
{ 0 } [ 5 <bit-set> cardinality ] unit-test
{ 2 } [ 5 <bit-set> 0 over adjoin 1 over adjoin cardinality ] unit-test
{ 1 } [ 5 <bit-set> 1 over adjoin cardinality ] unit-test

{ { } } [ { } { } within ] unit-test
{ { 2 3 } } [ { 1 2 3 } { 2 3 4 } within ] unit-test
{ { 2 2 3 } } [ { 1 2 2 3 } { 2 3 3 4 } within ] unit-test

{ { } } [ { } { } without ] unit-test
{ { 1 } } [ { 1 2 3 } { 2 3 4 } without ] unit-test
{ { 1 1 } } [ { 1 1 2 3 3 } { 2 3 4 4 } without ] unit-test

{ f } [ { } union-all ] unit-test
{ { 1 2 3 } } [ { { 1 } { 2 } { 1 3 } } union-all ] unit-test

{ f } [ { } intersect-all ] unit-test
{ HS{ } } [ { HS{ } } intersect-all ] unit-test
{ HS{ 1 } } [ { HS{ 1 2 3 } HS{ 1 } } intersect-all ] unit-test
{ { 2 } } [ { { 2 3 } { 2 4 } { 9 8 4 2 } } intersect-all ] unit-test

{ { 1 4 9 16 25 36 } }
[ { { 1 2 3 } { 4 5 6 } } [ [ sq ] map ] gather ] unit-test

{ H{ { 3 HS{ 1 2 } } } } [ H{ } clone 1 3 pick adjoin-at 2 3 pick adjoin-at ] unit-test

TUPLE: null-set ;
INSTANCE: null-set set
M: null-set members drop f ;

{ 0 } [ T{ null-set } cardinality ] unit-test
{ f } [ T{ null-set } members ] unit-test
{ t } [ T{ null-set } T{ null-set } set-like T{ null-set } = ] unit-test

{ t } [ T{ null-set } set? ] unit-test
{ t } [ HS{ } set? ] unit-test
{ t } [ { } set? ] unit-test
{ t } [ 5 <bit-set> set? ] unit-test
{ f } [ H{ } set? ] unit-test

{ HS{ } } [ HS{ } [ clear-set ] keep ] unit-test
{ HS{ } } [ HS{ 1 2 3 } [ clear-set ] keep ] unit-test

{ HS{ } } [ HS{ } HS{ } union! ] unit-test
{ HS{ 1 } } [ HS{ 1 } HS{ } union! ] unit-test
{ HS{ 1 } } [ HS{ } HS{ 1 } union! ] unit-test
{ HS{ 1 2 3 } } [ HS{ 1 } HS{ 1 2 3 } union! ] unit-test

{ HS{ } } [ HS{ } HS{ } diff! ] unit-test
{ HS{ 1 } } [ HS{ 1 2 3 } HS{ 2 3 } diff! ] unit-test
{ HS{ 1 } } [ HS{ 1 } HS{ 2 3 4 } diff! ] unit-test
{ HS{ 1 2 3 } } [ HS{ 1 2 3 } HS{ 4 } diff! ] unit-test

{ HS{ } } [ HS{ } HS{ } intersect! ] unit-test
{ HS{ 2 3 } } [ HS{ 1 2 3 } HS{ 2 3 } intersect! ] unit-test
{ HS{ } } [ HS{ 1 } HS{ 2 3 4 } intersect! ] unit-test
{ HS{ } } [ HS{ 1 2 3 } HS{ 4 } intersect! ] unit-test
