! Copyright (C) 2010 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors hash-sets kernel math prettyprint sequences
sets sorting tools.test ;

{ { 1 2 3 } } [ HS{ 1 2 3 } members sort ] unit-test

{ "HS{ 1 2 3 4 }" } [ HS{ 1 2 3 4 } unparse ] unit-test

{ t } [ 1 HS{ 0 1 2 } in? ] unit-test
{ f } [ 3 HS{ 0 1 2 } in? ] unit-test
{ HS{ 1 2 3 } } [ 3 HS{ 1 2 } clone [ adjoin ] keep ] unit-test
{ HS{ 1 2 } } [ 2 HS{ 1 2 } clone [ adjoin ] keep ] unit-test
{ t } [ 1 HS{ } ?adjoin ] unit-test
{ f } [ 1 HS{ 1 } ?adjoin ] unit-test
{ HS{ 1 2 3 } } [ 4 HS{ 1 2 3 } clone [ delete ] keep ] unit-test
{ HS{ 1 2 } } [ 3 HS{ 1 2 3 } clone [ delete ] keep ] unit-test
{ t } [ 1 HS{ 1 } ?delete ] unit-test
{ f } [ 1 HS{ } ?delete ] unit-test
{ HS{ 1 2 } } [ HS{ 1 2 } fast-set ] unit-test
{ { 1 2 } } [ HS{ 1 2 } members sort ] unit-test

{ HS{ 1 2 3 4 } } [ HS{ 1 2 3 } HS{ 2 3 4 } union ] unit-test
{ HS{ 2 3 } } [ HS{ 1 2 3 } HS{ 2 3 4 } intersect ] unit-test
{ t } [ HS{ 1 2 3 } HS{ 2 3 4 } intersects? ] unit-test
{ f } [ HS{ 1 } HS{ 2 3 4 } intersects? ] unit-test
{ f } [ HS{ 1 } HS{ 2 3 4 } subset? ] unit-test
{ f } [ HS{ 1 2 3 } HS{ 2 3 4 } subset? ] unit-test
{ t } [ HS{ 2 3 } HS{ 2 3 4 } subset? ] unit-test
{ t } [ HS{ } HS{ 2 3 4 } subset? ] unit-test
{ HS{ 1 } } [ HS{ 1 2 3 } HS{ 2 3 4 } diff ] unit-test
{ t } [ HS{ 1 2 3 } HS{ 2 1 3 } set= ] unit-test
{ t } [ HS{ 1 2 3 } HS{ 2 1 3 } = ] unit-test
{ f } [ HS{ 2 3 } HS{ 2 1 3 } set= ] unit-test
{ f } [ HS{ 1 2 3 } HS{ 2 3 } set= ] unit-test

{ HS{ 1 2 } HS{ 1 2 3 } } [ HS{ 1 2 } clone dup clone [ 3 swap adjoin ] keep ] unit-test

{ t } [ HS{ } null? ] unit-test
{ f } [ HS{ 1 } null? ] unit-test

{ { } } [ { 1 2 3 } duplicates ] unit-test
{ f } [ { 1 2 3 } >hash-set duplicates ] unit-test
{ { 1 } } [ { 1 2 1 } duplicates ] unit-test

{ HS{ HS{ { 2 1 } { 1 2 } } } } [
    HS{ } clone
    HS{ { 1 2 } { 2 1 } } over adjoin
    HS{ { 2 1 } { 1 2 } } over adjoin
] unit-test

! make sure growth and capacity use same load-factor
{ t } [
    100 <iota>
    [ [ <hash-set> ] map ]
    [ [ HS{ } clone [ '[ _ adjoin ] each-integer ] keep ] map ] bi
    [ [ array>> length ] bi@ = ] 2all?
] unit-test

! non-integer capacity not allowed
[ 0.75 <hash-set> ] must-fail

{ t } [ "test" dup HS{ } clone intern eq? ] unit-test
{ t } [ "aoeu" dup clone HS{ } clone intern = ] unit-test
{ t } [ "snth" dup clone HS{ } clone intern eq? not ] unit-test
