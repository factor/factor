IN: temporary
USING: arrays compiler kernel kernel-internals lists math
sequences strings test vectors sequences-internals ;

: <range> ( from to -- seq ) dup <slice> ; inline

: list-iter 100 [ 0 100000 <range> >list [ ] map drop ] times ; compiled
: vector-iter 100 [ 0 100000 <range> >vector [ ] map drop ] times ; compiled
: array-iter 100 [ 0 100000 <range> >array [ ] map drop ] times ; compiled
: string-iter 100 [ 0 100000 <range> >string [ ] map drop ] times ; compiled
: sbuf-iter 100 [ 0 100000 <range> >sbuf [ ] map drop ] times ; compiled
: reverse-iter 100 [ 0 100000 <range> >vector <reversed> [ ] map drop ] times ; compiled
: dot-iter 100 [ 0 100000 <range> dup v. drop ] times ; compiled

[ ] [ list-iter ] unit-test
[ ] [ vector-iter ] unit-test
[ ] [ array-iter ] unit-test
[ ] [ string-iter ] unit-test
[ ] [ sbuf-iter ] unit-test
[ ] [ reverse-iter ] unit-test
