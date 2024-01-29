USING: math.vectors tools.test kernel ranges arrays ;

{ { 3 12 21 30 } } [ 3 1 10 3 <range> n*v >array ] unit-test
{ { 3 12 21 30  } } [ 1 10 3 <range> 3 v*n >array ] unit-test
{ { 4 7 10 13 } } [ 3 1 10 3 <range> n+v >array ] unit-test
{ { 4 7 10 13 } } [ 1 10 3 <range> 3 v+n >array ] unit-test
{ { 2 -1 -4 -7 } } [ 3 1 10 3 <range> n-v >array ] unit-test
{ { -2 1 4 7 } } [ 1 10 3 <range> 3 v-n >array ] unit-test
{ { 1/3 4/3 7/3 10/3 } } [ 1 10 3 <range> 3 v/n >array ] unit-test
{ { 6 11 16 21 } } [ 1 10 3 <range> 5 20 2 <range> v+ >array ] unit-test
{ { -4 -3 -2 -1 } } [ 1 10 3 <range> 5 20 2 <range> v- >array ] unit-test

{ { 3 11/2 8 21/2 } } [ 1 10 3 <range> 5 20 2 <range> vavg >array ] unit-test
{ { -1 -4 -7 -10 } } [ 1 10 3 <range> vneg >array ] unit-test
