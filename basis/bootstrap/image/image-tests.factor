IN: bootstrap.image.tests
USING: bootstrap.image bootstrap.image.private tools.test
kernel math ;

[ f ] [ { 1 2 3 } [ 1 2 3 ] eql? ] unit-test

[ t ] [ [ 1 2 3 ] [ 1 2 3 ] eql? ] unit-test

[ f ] [ [ 2drop 0 ] [ 2drop 0.0 ] eql? ] unit-test

[ t ] [ [ 2drop 0 ] [ 2drop 0 ] eql? ] unit-test

[ f ] [ \ + [ 2drop 0 ] eql? ] unit-test

[ f ] [ 3 [ 0 1 2 ] eql? ] unit-test

[ f ] [ 3 3.0 eql? ] unit-test

[ t ] [ 4.0 4.0 eql? ] unit-test
