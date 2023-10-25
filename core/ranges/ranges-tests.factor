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

{ t } [ 4 4 10 2 <range> in? ] unit-test
{ t } [ 6 4 10 2 <range> in? ] unit-test
{ t } [ 10 4 10 2 <range> in? ] unit-test
{ t } [ -6 4 -10 -2 <range> in? ] unit-test
{ t } [ 6 10 4 -1 <range> in? ] unit-test

{ f } [ 5 4 10 2 <range> in? ] unit-test
{ f } [ 3 4 10 2 <range> in? ] unit-test
{ f } [ 4.0 4 10 2 <range> in? ] unit-test
{ f } [ 6.0 4 10 2 <range> in? ] unit-test
{ f } [ 10.0 4 10 2 <range> in? ] unit-test

{ { } } [ 1 8 2 <range> 2 9 2 <range> intersect >array ] unit-test
{ { } } [ 1 8 2 <range> 8 1 -2 <range> intersect >array ] unit-test
{ { } } [ 1 -9 1 <range> 1 8 1 <range> intersect >array ] unit-test
{ { 13 19 25 31 37 43 49 } } [
    1 100 3 <range> 11 50 2 <range> intersect >array ] unit-test
{ { 6 } } [
    6 7 1 <range> 6 -20 -4 <range> intersect >array ] unit-test
{ { 3 3+1/3 3+2/3 4 4+1/3 4+2/3 5 } } [
    2 5 1/3 <range> 3 10 1/3 <range> intersect >array ] unit-test
{ { 1.0 1.5 2.0 } } [
    1.0 2.0 0.25 <range> 1.0 2.0 0.5 <range> intersect >array ] unit-test

{ f } [ 1 8 2 <range> 2 9 2 <range> intersects? ] unit-test
{ f } [ 1 8 2 <range> 8 1 -2 <range> intersects? ] unit-test
{ f } [ 1 -9 1 <range> 1 8 1 <range> intersects? ] unit-test
{ t } [ 1 100 3 <range> 11 50 2 <range> intersects? ] unit-test
{ t } [ 6 7 1 <range> 6 -20 -4 <range> intersects? ] unit-test

{ t } [ 6 9 2 <range> 6 8 2 <range> set= ] unit-test
{ t } [ 2 9 2 <range> 8 1 -2 <range> set= ] unit-test
{ t } [ 9 0 3 <range> 4 8 -2 <range> set= ] unit-test
{ f } [ 1 8 1 <range> 1 8 2 <range> set= ] unit-test

{ t } [ 3 10 4 <range> 1 10 2 <range> subset? ] unit-test
{ t } [ 1 0 1 <range> 10 2 1 <range> subset? ] unit-test
{ f } [ 1 10 2 <range> 3 10 4 <range> subset? ] unit-test

{ { 1.5 2.5 3.5 } } [ 1.5 3.7 [a..b) >array ] unit-test
{ { 1+1/2 2+1/2 3+1/2 } } [ 3/2 37/10 [a..b) >array ] unit-test
