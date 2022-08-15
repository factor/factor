USING: arrays kernel math ranges sequences sets tools.test ;

{ { } } [ 1 1 (a..b) >array ] unit-test
{ { } } [ 1 1 (a..b] >array ] unit-test
{ { } } [ 1 1 [a..b) >array ] unit-test
{ { 1 } } [ 1 1 [a..b] >array ] unit-test

{ { }  } [ 1 2 (a..b) >array ] unit-test
{ { 2 } } [ 1 2 (a..b] >array ] unit-test
{ { 1 } } [ 1 2 [a..b) >array ] unit-test
{ { 1 2 } } [ 1 2 [a..b] >array ] unit-test

{ { } } [ 2 1 (a..b) >array ] unit-test
{ { 1 } } [ 2 1 (a..b] >array ] unit-test
{ { 2 } } [ 2 1 [a..b) >array ] unit-test
{ { 2 1 } } [ 2 1 [a..b] >array ] unit-test

{ { 1 2 3 4 5 } } [ 1 5 1 <range> >array ] unit-test
{ { 5 4 3 2 1 } } [ 5 1 -1 <range> >array ] unit-test

{ { 0 1/3 2/3 1 } } [ 0 1 1/3 <range> >array ] unit-test
{ { 0 1/3 2/3 1 } } [ 1 0 -1/3 <range> >array reverse ] unit-test

{ 0 } [ 0 -1 .0001 <range> length ] unit-test
{ 0 } [ 0 -1 .5 <range> length ] unit-test
{ 0 } [ 0 -1 1 <range> length ] unit-test
{ 0 } [ 0 -1 2 <range> length ] unit-test
{ 0 } [ 0 -1 3 <range> length ] unit-test
{ 0 } [ 0 -1 4 <range> length ] unit-test

{ 0 } [ 0 -2 .0001 <range> length ] unit-test
{ 0 } [ 0 -2 1 <range> length ] unit-test
{ 0 } [ 0 -2 2 <range> length ] unit-test
{ 0 } [ 0 -2 3 <range> length ] unit-test
{ 0 } [ 0 -2 4 <range> length ] unit-test

{ 0 } [ -1 0 -.0001 <range> length ] unit-test
{ 0 } [ -1 0 -.5 <range> length ] unit-test
{ 0 } [ -1 0 -1 <range> length ] unit-test
{ 0 } [ -1 0 -2 <range> length ] unit-test
{ 0 } [ -1 0 -3 <range> length ] unit-test
{ 0 } [ -1 0 -4 <range> length ] unit-test

{ 0 } [ -2 0 -.0001 <range> length ] unit-test
{ 0 } [ -2 0 -1 <range> length ] unit-test
{ 0 } [ -2 0 -2 <range> length ] unit-test
{ 0 } [ -2 0 -3 <range> length ] unit-test
{ 0 } [ -2 0 -4 <range> length ] unit-test

{ 100 } [
    1 100 [a..b] [ 2^ [1..b] ] map members length
] unit-test

{ t } [ -10 10 1 <range> [ sum ] [ >array sum ] bi = ] unit-test
{ t } [ -10 10 2 <range> [ sum ] [ >array sum ] bi = ] unit-test
{ t } [ 10 -10 -1 <range> [ sum ] [ >array sum ] bi = ] unit-test
{ t } [ 10 -10 -2 <range> [ sum ] [ >array sum ] bi = ] unit-test

! Empty range
{ 0 } [ 1 0 1 <range> sum ] unit-test
