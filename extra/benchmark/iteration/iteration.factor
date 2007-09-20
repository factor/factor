IN: benchmark.iteration
USING: sequences vectors arrays strings sbufs math math.vectors
kernel ;

: <range> ( from to -- seq ) dup <slice> ; inline

: vector-iter 100 [ 0 100000 <range> >vector [ ] map drop ] times ;
: array-iter 100 [ 0 100000 <range> >array [ ] map drop ] times ;
: string-iter 100 [ 0 100000 <range> >string [ ] map drop ] times ;
: sbuf-iter 100 [ 0 100000 <range> >sbuf [ ] map drop ] times ;
: reverse-iter 100 [ 0 100000 <range> >vector <reversed> [ ] map drop ] times ;
: dot-iter 100 [ 0 100000 <range> dup v. drop ] times ;

: iter-main
    vector-iter
    array-iter
    string-iter
    sbuf-iter
    reverse-iter ;

MAIN: iter-main
