IN: temporary
USING: arrays compiler kernel kernel-internals math
sequences strings test vectors sequences-internals ;

: <range> ( from to -- seq ) dup <slice> ; inline

: vector-iter 100 [ 0 100000 <range> >vector [ ] map drop ] times ;
: array-iter 100 [ 0 100000 <range> >array [ ] map drop ] times ;
: string-iter 100 [ 0 100000 <range> >string [ ] map drop ] times ;
: sbuf-iter 100 [ 0 100000 <range> >sbuf [ ] map drop ] times ;
: reverse-iter 100 [ 0 100000 <range> >vector <reversed> [ ] map drop ] times ;
: dot-iter 100 [ 0 100000 <range> dup v. drop ] times ;

[ ] [ vector-iter ] unit-test
[ ] [ array-iter ] unit-test
[ ] [ string-iter ] unit-test
[ ] [ sbuf-iter ] unit-test
[ ] [ reverse-iter ] unit-test
